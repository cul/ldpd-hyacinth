import React from 'react';
import { Row, Col, Button, Card } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';
import produce from 'immer';

import ContextualNavbar from '../layout/ContextualNavbar';
import hyacinthApi from '../../util/hyacinth_api';
import DynamicFieldGroupForm from './DynamicFieldGroupForm';
import DynamicFieldsBreadcrumbs from '../layout/dynamic_fields/DynamicFieldsBreadcrumbs';

class DynamicFieldGroupEdit extends React.Component {
  render() {
    const { match: { params: { id } } } = this.props;

    return (
      <>
        <ContextualNavbar
          title="Update Dynamic Field Group"
          rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
        />

        <DynamicFieldsBreadcrumbs
          for={{ id: id, type: 'DynamicFieldGroup' }}
        />

        <DynamicFieldGroupForm key={id} id={id} formType="edit"
        />
      </>
    );
  }
}

export default DynamicFieldGroupEdit;
