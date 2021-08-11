import React, { useState } from 'react';
import { Row, Col, Form, Button } from 'react-bootstrap';
import { useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';

import ContextualNavbar from '../shared/ContextualNavbar';
import { createProjectMutation } from '../../graphql/projects';
import GraphQLErrors from '../shared/GraphQLErrors';

function ProjectNew() {
  const [stringKey, setStringKey] = useState('');
  const [displayLabel, setDisplayLabel] = useState('');
  const [projectUrl, setProjectUrl] = useState('');
  const [hasAssetRights, setHasAssetRights] = useState(false);

  const [createProject, { error }] = useMutation(createProjectMutation);
  const history = useHistory();

  const handleSubmit = (e) => {
    e.preventDefault();
    createProject({
      variables: {
        input: {
          stringKey,
          displayLabel,
          projectUrl,
          hasAssetRights,
        },
      },
    }).then((res) => {
      history.push(`/projects/${res.data.createProject.project.stringKey}/core_data/edit`);
    });
  };

  return (
    <>
      <ContextualNavbar
        title="Create New Project"
        rightHandLinks={[{ link: '/projects', label: 'Cancel' }]}
      />

      <GraphQLErrors errors={error} />

      <Form onSubmit={handleSubmit}>
        <Row>
          <Col sm={6}>
            <Form.Label>String Key</Form.Label>
            <Form.Control
              type="text"
              name="stringKey"
              value={stringKey}
              onChange={e => setStringKey(e.target.value)}
            />
          </Col>

          <Col sm={6}>
            <Form.Label>Display Label</Form.Label>
            <Form.Control
              type="text"
              name="displayLabel"
              value={displayLabel}
              onChange={e => setDisplayLabel(e.target.value)}
            />
          </Col>
        </Row>

        <Row>
          <Col>
            <Form.Label>Project URL</Form.Label>
            <Form.Control
              type="text"
              name="projectUrl"
              value={projectUrl}
              onChange={e => setProjectUrl(e.target.value)}
            />
          </Col>
        </Row>

        <Row className="my-3">
          <Col>
            <Form.Check
              type="checkbox"
              name="hasAssetRights"
              value={hasAssetRights}
              label="Asset Rights?"
              onChange={e => setHasAssetRights(e.target.checked)}
              checked={hasAssetRights}
            />
          </Col>
        </Row>

        <Button variant="primary" type="submit" onClick={handleSubmit}>Create</Button>
      </Form>
    </>
  );
}

export default ProjectNew;
