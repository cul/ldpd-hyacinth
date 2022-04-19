import React from 'react';
import { Row, Col } from 'react-bootstrap';
import { useHistory } from 'react-router-dom';
import { useQuery, useMutation } from '@apollo/react-hooks';
import PropTypes from 'prop-types';

import GraphQLErrors from '../../shared/GraphQLErrors';
import TabHeading from '../../shared/tabs/TabHeading';
import DigitalObjectInterface from '../DigitalObjectInterface';
import DeleteButton from '../../shared/forms/buttons/DeleteButton';
import PurgeButton from '../../shared/forms/buttons/PurgeButton';
import {
  getSystemDataDigitalObjectQuery,
  deleteDigitalObjectMutation,
  purgeDigitalObjectMutation,
} from '../../../graphql/digitalObjects';
import ProjectsEdit from '../projects/ProjectsEdit';
import ProjectsShow from '../projects/ProjectsShow';
import { digitalObjectAbility } from '../../../utils/ability';

function SystemData(props) {
  const { id } = props;
  const history = useHistory();
  const [deleteDigitalObject, { error: deleteError }] = useMutation(deleteDigitalObjectMutation);
  const [purgeDigitalObject, { error: purgeError }] = useMutation(purgeDigitalObjectMutation);

  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
  } = useQuery(getSystemDataDigitalObjectQuery, {
    variables: { id },
  });

  if (digitalObjectLoading) return (<></>);
  if (digitalObjectError) return (<GraphQLErrors errors={digitalObjectError} />);
  const { digitalObject } = digitalObjectData;

  const canDeleteObject = digitalObjectAbility.can('delete_objects', {
    primaryProject: digitalObject.primaryProject, otherProjects: digitalObject.otherProjects,
  });
  const canPurgeObject = digitalObjectAbility.can('purge_objects', {
    primaryProject: digitalObject.primaryProject, otherProjects: digitalObject.otherProjects,
  });
  const canUpdateObject = digitalObjectAbility.can('update_objects', {
    primaryProject: digitalObject.primaryProject, otherProjects: digitalObject.otherProjects,
  });

  const onDelete = (e) => {
    e.preventDefault();

    const variables = { input: { id: digitalObject.id } };

    deleteDigitalObject({ variables }).then(() => history.push('/digital_objects'));
  };

  const onPurge = (e) => {
    e.preventDefault();

    const variables = { input: { id: digitalObject.id } };

    purgeDigitalObject({ variables }).then(() => history.push('/digital_objects'));
  };

  const renderDeleteSection = () => {
    if (!canDeleteObject) return '';

    return (
      <>
        <hr />
        <h4>Delete Digital Object</h4>
        <DeleteButton formType="edit" onClick={onDelete} />
      </>
    );
  };

  const renderPurgeSection = () => {
    if (!canPurgeObject) return '';

    return (
      <>
        <hr />
        <h4>Purge Digital Object</h4>
        <PurgeButton formType="edit" onClick={onPurge} />
      </>
    );
  };

  const {
    state, createdBy, createdAt, updatedBy, updatedAt, firstPublishedAt,
  } = digitalObject;

  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <TabHeading>System Data</TabHeading>

      <GraphQLErrors errors={deleteError || purgeError} />

      <Row as="dl">
        <Col as="dt" lg={2} sm={4}>Created By</Col>
        <Col as="dd" lg={10} sm={8}>{createdBy ? createdBy.fullName : '-- Not Assigned --'}</Col>

        <Col as="dt" lg={2} sm={4}>Created On</Col>
        <Col as="dd" lg={10} sm={8}>{createdAt || '-- Assigned After Save --'}</Col>

        <Col as="dt" lg={2} sm={4}>Last Modified By</Col>
        <Col as="dd" lg={10} sm={8}>{updatedBy ? updatedBy.fullName : '-- Not Assigned --'}</Col>

        <Col as="dt" lg={2} sm={4}>Last Modified On</Col>
        <Col as="dd" lg={10} sm={8}>{updatedAt || '-- Assigned After Save --'}</Col>

        <Col as="dt" lg={2} sm={4}>First Published At</Col>
        <Col as="dd" lg={10} sm={8}>{firstPublishedAt || '-- Assigned After Publish --'}</Col>
      </Row>
      <hr />
      {canUpdateObject ? <ProjectsEdit digitalObject={digitalObject} /> : <ProjectsShow digitalObject={digitalObject} />}
      {state === 'ACTIVE' && renderDeleteSection()}
      {renderPurgeSection()}
    </DigitalObjectInterface>
  );
}

export default SystemData;

SystemData.propTypes = {
  id: PropTypes.string.isRequired,
};
