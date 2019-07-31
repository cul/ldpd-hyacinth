import React from 'react';
import produce from 'immer';
import { Form } from 'react-bootstrap';

import Checkbox from '../ui/forms/inputs/Checkbox';
import InputGroup from '../ui/forms/InputGroup';
import FormButtons from '../ui/forms/FormButtons';
import hyacinthApi from '../../util/hyacinth_api';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';
import { Can } from '../../util/ability_context';

class SystemWidePermissionsForm extends React.Component {
  state = {
    user: {
      uid: '',
      isAdmin: false,
      systemWidePermissions: [],
    },
  }

  componentDidMount = () => {
    const { user: { uid, isAdmin, systemWidePermissions } } = this.props;

    this.setState(produce((draft) => {
      draft.user.uid = uid;
      draft.user.isAdmin = isAdmin;
      draft.user.systemWidePermissions = systemWidePermissions;
    }));
  }

  onSubmitHandler = () => {
    const { user: { uid, isAdmin, systemWidePermissions } } = this.state;

    const data = { user: { isAdmin, permissions: systemWidePermissions } };
    return hyacinthApi.patch(`/users/${uid}`, data);
  }

  onIsAdminChange = (v) => {
    this.setState(produce((draft) => {
      draft.user.isAdmin = v;
      if (v) draft.user.systemWidePermissions = [];
    }));
  }

  onChangeSystemWidePermissions = (permission, v) => {
    const { user: { systemWidePermissions } } = this.state;

    if (v && !systemWidePermissions.includes(permission)) {
      this.setState(produce((draft) => {
        draft.user.isAdmin = false;
        draft.user.systemWidePermissions.push(permission);
      }));
    } else if (!v) {
      this.setState(produce((draft) => {
        draft.user.isAdmin = false;
        draft.user.systemWidePermissions = systemWidePermissions.filter(p => p !== permission);
      }));
    }
  }

  render() {
    const { user: { isAdmin, systemWidePermissions } } = this.state;

    return (
      <Form>
        <h5>System Wide Permissions</h5>
        <InputGroup>
          <Can I="manage" a="all">
            <Checkbox
              sm={12}
              value={isAdmin}
              label="Administrator"
              onChange={v => this.onIsAdminChange(v)}
              helpText="has ability to perform all actions"
            />
          </Can>
          <Checkbox
            sm={12}
            md={6}
            value={systemWidePermissions.includes('manage_vocabularies')}
            label="Manage Vocabularies"
            onChange={v => this.onChangeSystemWidePermissions('manage_vocabularies', v)}
            helpText="has ability to create/edit/delete vocabularies, and create/edit/delete terms"
          />
          <Checkbox
            md={6}
            sm={12}
            value={systemWidePermissions.includes('manage_users')}
            label="Manage Users"
            onChange={v => this.onChangeSystemWidePermissions('manage_users', v)}
            helpText="has ability to add new users, deactivate users, and add all system-wide permissions except administrator"
          />
          <Checkbox
            md={6}
            sm={12}
            value={systemWidePermissions.includes('read_all_digital_objects')}
            label="Read All Digital Objects"
            onChange={v => this.onChangeSystemWidePermissions('read_all_digital_objects', v)}
            helpText="has ability to view all projects and all digital objects"
          />
          <Checkbox
            md={6}
            sn={12}
            value={systemWidePermissions.includes('manage_all_digital_objects')}
            onChange={v => this.onChangeSystemWidePermissions('manage_all_digital_objects', v)}
            label="Manage All Digital Objects"
            helpText="has ability to read/create/edit/delete all digital objects and view all projects"
          />
        </InputGroup>
        <FormButtons
          onSave={this.onSubmitHandler}
        />
      </Form>
    );
  }
}

export default withErrorHandler(SystemWidePermissionsForm, hyacinthApi);
