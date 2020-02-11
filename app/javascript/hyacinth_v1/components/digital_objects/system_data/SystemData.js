import React from 'react';
import { Row, Col } from 'react-bootstrap';
import { useHistory } from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';
import PropTypes from 'prop-types';

import GraphQLErrors from '../../shared/GraphQLErrors';
import TabHeading from '../../shared/tabs/TabHeading';
import DigitalObjectInterface from '../DigitalObjectInterface';
import DeleteButton from '../../shared/forms/buttons/DeleteButton';
import { getSystemDataDigitalObjectQuery } from '../../../graphql/digitalObjects';
import { digitalObject as digitalObjectApi } from '../../../utils/hyacinth_api';
import { digitalObjectAbility } from '../../../utils/ability';

function SystemData(props) {
  const { id } = props;
  const history = useHistory();

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

  const canDeleteObject = digitalObjectAbility.can('delete_objects', { primaryProject: digitalObject.primaryProject, otherProjects: digitalObject.otherProjects });

  const onDelete = (e) => {
    e.preventDefault();
    digitalObjectApi.delete(id).then(() => history.push('/digital_objects'));
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
  }

  const {
    createdBy, createdAt, updatedBy, updatedAt, firstPublishedAt,
    primaryProject, otherProjects,
  } = digitalObject;

  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <TabHeading>System Data</TabHeading>
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
      <h4>Primary Project</h4>
      <p>{primaryProject.displayLabel}</p>
      <h4>Other Projects</h4>
      <p>{otherProjects.length ? otherProjects.map(p => p.displayLabel).join(', ') : 'None'}</p>
      { renderDeleteSection() }
    </DigitalObjectInterface>
  );
}


export default SystemData;

SystemData.propTypes = {
  id: PropTypes.string.isRequired,
};
