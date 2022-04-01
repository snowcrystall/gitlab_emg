import { shallowMount } from '@vue/test-utils';
import AxiosMockAdapter from 'axios-mock-adapter';
import Vue, { nextTick } from 'vue';

import { TEST_HOST } from 'helpers/test_constants';
import { listObj } from 'jest/boards/mock_data';
import Board from '~/boards/components/board_column_deprecated.vue';
import { ListType } from '~/boards/constants';
import List from '~/boards/models/list';
import axios from '~/lib/utils/axios_utils';

describe('Board Column Component', () => {
  let wrapper;
  let axiosMock;

  beforeEach(() => {
    window.gon = {};
    axiosMock = new AxiosMockAdapter(axios);
    axiosMock.onGet(`${TEST_HOST}/lists/1/issues`).reply(200, { issues: [] });
  });

  afterEach(() => {
    axiosMock.restore();

    wrapper.destroy();

    localStorage.clear();
  });

  const createComponent = ({
    listType = ListType.backlog,
    collapsed = false,
    highlighted = false,
    withLocalStorage = true,
  } = {}) => {
    const boardId = '1';

    const listMock = {
      ...listObj,
      list_type: listType,
      highlighted,
      collapsed,
    };

    if (listType === ListType.assignee) {
      delete listMock.label;
      listMock.user = {};
    }

    // Making List reactive
    const list = Vue.observable(new List(listMock));

    if (withLocalStorage) {
      localStorage.setItem(
        `boards.${boardId}.${list.type}.${list.id}.expanded`,
        (!collapsed).toString(),
      );
    }

    wrapper = shallowMount(Board, {
      propsData: {
        boardId,
        disabled: false,
        list,
      },
      provide: {
        boardId,
      },
    });
  };

  const isExpandable = () => wrapper.classes('is-expandable');
  const isCollapsed = () => wrapper.classes('is-collapsed');

  describe('Given different list types', () => {
    it('is expandable when List Type is `backlog`', () => {
      createComponent({ listType: ListType.backlog });

      expect(isExpandable()).toBe(true);
    });
  });

  describe('expanded / collapsed column', () => {
    it('has class is-collapsed when list is collapsed', () => {
      createComponent({ collapsed: false });

      expect(wrapper.vm.list.isExpanded).toBe(true);
    });

    it('does not have class is-collapsed when list is expanded', () => {
      createComponent({ collapsed: true });

      expect(isCollapsed()).toBe(true);
    });
  });

  describe('highlighting', () => {
    it('scrolls to column when highlighted', async () => {
      createComponent({ highlighted: true });

      await nextTick();

      expect(wrapper.element.scrollIntoView).toHaveBeenCalled();
    });
  });
});
