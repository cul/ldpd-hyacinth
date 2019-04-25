import React from 'react'
import { Link } from "react-router-dom";
import { Row, Col, Form, Button } from 'react-bootstrap';
import produce from "immer";

import ProjectSubHeading from 'hyacinth_ui_v1/hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading'
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';
import FieldSetForm from './FieldSetForm'
import withErrorHandler from 'hyacinth_ui_v1/hoc/withErrorHandler/withErrorHandler';

class FieldSetEdit extends React.Component {
  updateFieldSet = (data) => {
    hyacinthApi.patch(this.props.match.url.replace('edit', ''), data)
      .then(res => {
        this.props.history.push('/projects/'+ this.props.match.params.string_key + '/field_sets/');
      });
  }

  render() {
    return(
      <>
        <ProjectSubHeading>Edit Field Set</ProjectSubHeading>
        <FieldSetForm submitFormAction={this.updateFieldSet} submitButtonName="Update"/>
      </>
    )
  }
}

export default withErrorHandler(FieldSetEdit, hyacinthApi)
