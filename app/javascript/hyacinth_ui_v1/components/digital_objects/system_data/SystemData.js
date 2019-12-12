import React from 'react';
import { Form, Row, Col } from 'react-bootstrap';
import produce from 'immer';

import digitalObjectInterface from '../digitalObjectInterface';
import { digitalObject } from '../../../util/hyacinth_api';
import SelectInput from '../../ui/forms/inputs/SelectInput';
import DeleteButton from '../../ui/forms/buttons/DeleteButton';
import hyacinthApi, { projects } from '../../../util/hyacinth_api';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';

class SystemData extends React.Component {
  state = {
    projects: [],
    all_projects: [],
  }

  componentDidMount = () => {
    const { data: { projects: p } } = this.props;

    projects.all()
      .then((res) => {
        this.setState(produce((draft) => {
          draft.all_projects = res.data.projects;
          draft.projects = p;
        }));
      });
  }

  onDelete = (e) => {
    e.preventDefault();

    const { data: { uid }, history: { push } } = this.props;

    digitalObject.delete(uid).then(() => push('/digital_objects'));
  }

  onProjectChange = (v) => {
    const { data: { uid } } = this.props;

    // digitalObject.update(uid, { digitalObject: { projects: { stringKey: v } } })
  }

  render() {
    const {
      data: {
        pid,
        uid,
        doi,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        firstPublishedAt
      }
    } = this.props;
    const { projects, all_projects } = this.state;

    return (
      <>
        <Row as="dl">
          <Col as="dt" lg={2} sm={4}>Created By</Col>
          <Col as="dd" lg={10} sm={8}>{createdBy || '-- Assigned After Save --'}</Col>

          <Col as="dt" lg={2} sm={4}>Created On</Col>
          <Col as="dd" lg={10} sm={8}>{createdAt || '-- Assigned After Save --'}</Col>

          <Col as="dt" lg={2} sm={4}>Last Modified By</Col>
          <Col as="dd" lg={10} sm={8}>{updatedBy || '-- Assigned After Save --'}</Col>

          <Col as="dt" lg={2} sm={4}>Last Modified On</Col>
          <Col as="dd" lg={10} sm={8}>{updatedAt || '-- Assigned After Save --'}</Col>

          <Col as="dt" lg={2} sm={4}>First Published At</Col>
          <Col as="dd" lg={10} sm={8}>{firstPublishedAt || '-- Assigned After Publish --'}</Col>
        </Row>
        <hr />
        <h4>Primary Project</h4>
        <p>TODO</p>
        {/* <Form>
          {
            projects.length > 0 && (
              <SelectInput
                value={projects[0].stringKey}
                options={all_projects.map(p => ({ value: p.stringKey, label: p.displayLabel }))}
                onChange={this.onProjectChange}
              />
            )
          }
        </Form> */}
        <hr />
        <h4>Other Projects</h4>
        <p>TODO</p>
        <hr />
        <h4>Delete Dightal Object?</h4>
        <p>TODO: Description about what deleting does to a digital object.</p>
        <DeleteButton formType="edit" onClick={this.onDelete} />
      </>
    );
  }
}


export default digitalObjectInterface(withErrorHandler(SystemData, hyacinthApi));
