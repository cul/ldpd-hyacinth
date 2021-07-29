import React, { useState } from 'react';
import {
  Row, Col, Form, Button,
} from 'react-bootstrap';
import { useQuery, useMutation } from '@apollo/react-hooks';
import { useParams, useHistory } from 'react-router-dom';

import TabHeading from '../../shared/tabs/TabHeading';
import CancelButton from '../../shared/forms/buttons/CancelButton';
import SubmitButton from '../../shared/forms/buttons/SubmitButton';
import { Can } from '../../../utils/abilityContext';
import ProjectInterface from '../ProjectInterface';
import { getProjectQuery, updateProjectMutation, deleteProjectMutation } from '../../../graphql/projects';
import GraphQLErrors from '../../shared/GraphQLErrors';

function CoreDataEdit() {
  const { stringKey } = useParams();
  const history = useHistory();

  const [displayLabel, setDisplayLabel] = useState('');
  const [hasAssetRights, setHasAssetRights] = useState(false);
  const [projectUrl, setProjectUrl] = useState('');

  // Retrieve data and set data
  const { loading, error, data } = useQuery(
    getProjectQuery,
    {
      variables: { stringKey },
      onCompleted: (projectData) => {
        const { project } = projectData;

        setDisplayLabel(project.displayLabel);
        setProjectUrl(project.projectUrl);
        setHasAssetRights(project.hasAssetRights);
      },
    },
  );

  const [updateProject, { error: updateError }] = useMutation(updateProjectMutation);
  const [deleteProject, { error: deleteError }] = useMutation(deleteProjectMutation);

  const onSubmitHandler = (e) => {
    e.preventDefault();

    const variables = {
      input: {
          stringKey: data.project.stringKey, displayLabel, projectUrl, hasAssetRights,
      },
    };

    updateProject({ variables }).then(() => history.push(`/projects/${stringKey}/core_data`));
  };

  const onDeleteHandler = (e) => {
    e.preventDefault();

    const variables = { input: { stringKey: data.project.stringKey } };

    deleteProject({ variables }).then(() => history.push('/projects/'));
  };

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <ProjectInterface project={data.project}>
      <TabHeading>Editing Core Data</TabHeading>

      <GraphQLErrors errors={updateError || deleteError} />

      <Form as={Col} onSubmit={onSubmitHandler}>
        <Form.Group as={Row}>
          <Form.Label column sm={2}>String Key</Form.Label>
          <Col sm={10}>
            <Form.Control plaintext readOnly value={data.project.stringKey} />
          </Col>
        </Form.Group>

        <Form.Group as={Row}>
          <Form.Label column sm={2}>Display Label</Form.Label>
          <Col sm={10}>
            <Form.Control
              type="text"
              name="displayLabel"
              value={displayLabel}
              onChange={e => setDisplayLabel(e.target.value)}
            />
          </Col>
        </Form.Group>

        <Form.Group as={Row}>
          <Form.Label column sm={2}>Project URL</Form.Label>
          <Col sm={10}>
            <Form.Control
              type="text"
              name="projectUrl"
              value={projectUrl}
              onChange={e => setProjectUrl(e.target.value)}
            />
          </Col>
        </Form.Group>

        <Form.Group as={Row} className="my-3">
          <Col sm={10}>
            <Form.Check
              type="checkbox"
              name="hasAssetRights"
              value={hasAssetRights}
              label="Has Asset Rights"
              onChange={e => setHasAssetRights(e.target.checked)}
              checked={hasAssetRights}
            />
          </Col>
        </Form.Group>

        <Col>
          <Col sm="auto" className="mr-auto">
            <Can I="delete" a="Project">
              <Button variant="outline-danger" type="submit" onClick={onDeleteHandler}>Delete Project</Button>
            </Can>
          </Col>

          <Col sm="auto" className="ml-auto">
            <CancelButton to={`/projects/${stringKey}/core_data`} />
          </Col>

          <Col sm="auto">
            <SubmitButton formType="edit" onClick={onSubmitHandler} />
          </Col>
        </Col>
      </Form>
    </ProjectInterface>
  );
}

export default CoreDataEdit;
