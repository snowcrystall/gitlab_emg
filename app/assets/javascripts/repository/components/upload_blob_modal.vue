<script>
import {
  GlModal,
  GlForm,
  GlFormGroup,
  GlFormInput,
  GlFormTextarea,
  GlToggle,
  GlButton,
  GlAlert,
} from '@gitlab/ui';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { ContentTypeMultipartFormData } from '~/lib/utils/headers';
import { numberToHumanSize } from '~/lib/utils/number_utils';
import { visitUrl, joinPaths,refreshCurrentPage } from '~/lib/utils/url_utility';
import { __ } from '~/locale';
import { trackFileUploadEvent } from '~/projects/upload_file_experiment_tracking';
import UploadDropzone from '~/vue_shared/components/upload_dropzone/upload_dropzone.vue';
import {
  SECONDARY_OPTIONS_TEXT,
  COMMIT_LABEL,
  TARGET_BRANCH_LABEL,
  TOGGLE_CREATE_MR_LABEL,
} from '../constants';

const PRIMARY_OPTIONS_TEXT = __('Upload file');
const MODAL_TITLE = __('Upload New File');
const REMOVE_FILE_TEXT = __('Remove');
const NEW_BRANCH_IN_FORK = __(
  'A new branch will be created in your fork and a new merge request will be started.',
);
const ERROR_MESSAGE = __('Error uploading file. Please try again.');

const TABLE_FILE_NAME = __('File Name');
const TABLE_FILE_SIZE = __('File Size');
const TABLE_UPLOAD_PROGRESS = __('Progress');
const TABLE_OPERATION = __('Operation');

export default {
  components: {
    GlModal,
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlFormTextarea,
    GlToggle,
    GlButton,
    UploadDropzone,
    GlAlert,
  },
  i18n: {
    COMMIT_LABEL,
    TARGET_BRANCH_LABEL,
    TOGGLE_CREATE_MR_LABEL,
    REMOVE_FILE_TEXT,
    NEW_BRANCH_IN_FORK,
    TABLE_FILE_NAME,
    TABLE_FILE_SIZE,
    TABLE_UPLOAD_PROGRESS,
    TABLE_OPERATION,
  },
  props: {
    modalTitle: {
      type: String,
      default: MODAL_TITLE,
      required: false,
    },
    primaryBtnText: {
      type: String,
      default: PRIMARY_OPTIONS_TEXT,
      required: false,
    },
    modalId: {
      type: String,
      required: true,
    },
    commitMessage: {
      type: String,
      required: true,
    },
    targetBranch: {
      type: String,
      required: true,
    },
    originalBranch: {
      type: String,
      required: true,
    },
    canPushCode: {
      type: Boolean,
      required: true,
    },
    path: {
      type: String,
      required: true,
    },
    replacePath: {
      type: String,
      default: null,
      required: false,
    },
    singleFileSelection: {
      type: Boolean,
      default: false,
      required: false,
    },
    directorySelection: {
      type: Boolean,
      default: false,
      required: false,
    },
  },
  data() {
    return {
      commit: this.commitMessage,
      target: this.targetBranch,
      createNewMr: true,
      file: null, // FIXME remove latter
      filePreviewURL: null, // FIXME remove latter
      fileBinary: null, // FIXME remove latter
      files: null,
      loading: false,
    };
  },
  computed: {
    primaryOptions() {
      return {
        text: this.primaryBtnText,
        attributes: [
          {
            variant: 'confirm',
            loading: this.loading,
            disabled: !this.formCompleted || this.loading,
          },
        ],
      };
    },
    cancelOptions() {
      return {
        text: SECONDARY_OPTIONS_TEXT,
        attributes: [
          {
            disabled: this.loading,
          },
        ],
      };
    },
    formattedFileSize() {
      return numberToHumanSize(this.file.size);
    },
    showCreateNewMrToggle() {
      return this.canPushCode && this.target !== this.originalBranch;
    },
    formCompleted() {
      return this.files && this.commit && this.target;
    },
  },
  methods: {
    setFiles(files) {
      var records = [];
      for (let i = 0; i < files.length; i++) {
        var record = {};

        record.file = files[i];

        const fileUurlReader = new FileReader();

        fileUurlReader.readAsDataURL(record.file);

        fileUurlReader.onload = (e) => {
          record.filePreviewURL = e.target?.result;
        };

        records.push(record);
      }
      this.files = records;
      console.log('length: ' + this.files.length);
    },
    // FIXME remove latter
    setFile(file) {
      this.file = file;

      const fileUurlReader = new FileReader();

      fileUurlReader.readAsDataURL(this.file);

      fileUurlReader.onload = (e) => {
        this.filePreviewURL = e.target?.result;
      };
    },

    removeFile() {
      this.file = null;
      this.filePreviewURL = null;
    },
    removeSpecifiedFile(file) {
      if (this.files == null) {
        return;
      }

      var index = this.files.findIndex((item) => {
        if (this.directorySelection) {
          return item.file.webkitRelativePath == file.file.webkitRelativePath;
        } else {
          return item.file.name == file.file.name;
        }
      });

      this.files.splice(index, 1);

      if (this.files.length == 0) {
        this.files = null;
      }
    },
    submitForm() {
      if (this.directorySelection) {
        return this.uploadDir();
      }
      return this.replacePath ? this.replaceFile() : this.uploadFile();
    },
    submitRequest(method, url) {
      
      return axios({
        method,
        url,
        data: this.formData(),
        headers: {
          ...ContentTypeMultipartFormData,
        },
        onUploadProgress: (progressEvent) => {
          var processEvent = progressEvent;
          console.log('process: ' + JSON.stringify(progressEvent));
        },
      })
        .then((response) => {
          if (!this.replacePath) {
            trackFileUploadEvent('click_upload_modal_form_submit');
          }
          if (this.directorySelection) {
            visitUrl(response.data.FilePath);
          }else{
            visitUrl(response.data.filePath);
          }
		      //refreshCurrentPage()
        })
        .catch((error) => {
          this.loading = false;
		  console.log(error);
          createFlash({ message: ERROR_MESSAGE });
        });
    },
    formData() {
      const formData = new FormData();
      formData.append('branch_name', this.target);
      formData.append('create_merge_request', this.createNewMr);
      formData.append('commit_message', this.commit);

      formData.append('dir_commit', this.directorySelection);

      for (let i = 0; i < this.files.length; i++) {
        formData.append('file', this.files[i].file);
      }

      return formData;
    },
    replaceFile() {
      this.loading = true;

      // The PUT path can be geneated from $route (similar to "uploadFile") once router is connected
      // Follow-up issue: https://gitlab.com/gitlab-org/gitlab/-/issues/332736
      return this.submitRequest('put', this.replacePath);
    },
    uploadFile() {
      this.loading = true;
      const {
        $route: {
          params: { path },
        },
      } = this;
      const uploadPath = joinPaths(this.path, path);
      return this.submitRequest('post', uploadPath);
    },
    uploadDir() {
      this.loading = true;
      const {
        $route: {
          params: { path },
        },
      } = this;
      const uploadDirPath = joinPaths(this.path, path);
      return this.submitRequest('post', uploadDirPath);
    },
  },
  validFileMimetypes: [],
};
</script>
<template>
  <gl-form>
    <gl-modal
      :modal-id="modalId"
      :title="modalTitle"
      :action-primary="primaryOptions"
      :action-cancel="cancelOptions"
      @primary.prevent="submitForm"
    >
      <upload-dropzone
        class="gl-h-200! gl-mb-4"
        :single-file-selection="singleFileSelection"
        :directory-selection="directorySelection"
        :valid-file-mimetypes="$options.validFileMimetypes"
        @change="setFiles"
      >
        <table v-if="files" class="upload-dropzone-border">
          <thead>
            <tr>
              <th>{{ $options.i18n.TABLE_FILE_NAME }}</th>
              <th>{{ $options.i18n.TABLE_FILE_SIZE }}</th>
              <!--th styles="width: 40px">{{ $options.i18n.TABLE_UPLOAD_PROGRESS }}</th-->
              <th>{{ $options.i18n.TABLE_OPERATION }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="file in files">
              <td>{{ directorySelection ? file.file.webkitRelativePath : file.file.name }}</td>
              <td>{{ file.file.size }}</td>
              <!--td styles="witdh: 40px"> 0% </td-->
              <td>
                <gl-button
                  category="tertiary"
                  variant="confirm"
                  :disabled="loading"
                  styles="height:26px"
                  @click="removeSpecifiedFile(file)"
                  >{{ $options.i18n.REMOVE_FILE_TEXT }}</gl-button
                >
              </td>
            </tr>
          </tbody>
        </table>
      </upload-dropzone>
      <gl-form-group :label="$options.i18n.COMMIT_LABEL" label-for="commit_message">
        <gl-form-textarea v-model="commit" name="commit_message" :disabled="loading" />
      </gl-form-group>
      <gl-form-group
        v-if="canPushCode"
        :label="$options.i18n.TARGET_BRANCH_LABEL"
        label-for="branch_name"
      >
        <gl-form-input v-model="target" :disabled="loading" name="branch_name" />
      </gl-form-group>
      <gl-toggle
        v-if="showCreateNewMrToggle"
        v-model="createNewMr"
        :disabled="loading"
        :label="$options.i18n.TOGGLE_CREATE_MR_LABEL"
      />
      <gl-alert v-if="!canPushCode" variant="info" :dismissible="false" class="gl-mt-3">
        {{ $options.i18n.NEW_BRANCH_IN_FORK }}
      </gl-alert>
    </gl-modal>
  </gl-form>
</template>
<style>
table {
  border: 1px;
  border-collapse: collapse;
  border-radius: 3px;
  width: 100%;
  color: #000;
}
thead {
  width: 100%;
  padding-left: 5px;
  padding-right: 5px;
}
tbody {
  width: 100%;
  padding-left: 5px;
  padding-right: 5px;
  margin-bottom: 8px;
  display: block;
  overflow-x: hidden;
  overflow-y: auto;
  height: 160px;
}
th {
  padding-left: 5px;
}
thead,
tbody tr {
  display: table;
  table-layout: fixed;
  word-break: break-all;
  width: 100%;
}
</style>
