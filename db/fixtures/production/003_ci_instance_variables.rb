# id variable_type key secret_value protected masked _destroy
variables_params = { 
    variables_attributes: 
    [{
        id:'',
        #variable_type: ,
        key: 'SHARE_PROJECT_PATH',
        secret_value: 'D:\TEST_PROJECTS'
        #protected:
        #masked:
        #_destroy:
    }]
 }
service = Ci::UpdateInstanceVariablesService.new(variables_params)

service.execute