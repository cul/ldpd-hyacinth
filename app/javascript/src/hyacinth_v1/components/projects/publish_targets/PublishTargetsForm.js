import React, { useEffect, useState } from 'react';
import { useMutation, useQuery } from '@apollo/react-hooks';
import PropTypes from 'prop-types';
import {
  Row, Col, Form, Badge,
} from 'react-bootstrap';
import { useHistory } from 'react-router-dom';
import produce from 'immer';
import GraphQLErrors from '../../shared/GraphQLErrors';
import FormButtons from '../../shared/forms/FormButtons';
import { getProjectsPublishTargetsQuery, updateProjectsPublishTargetsMutation } from '../../../graphql/projects/publishTargets';

const PublishTarget = (props) => {
  const {
    stringKey, enabled, readOnly, enabledDataCallback,
  } = props;
  const onEnable = (event) => {
    const { target: { checked } } = event;
    if (enabled !== checked) {
      enabledDataCallback(stringKey, { enabled: checked });
    }
  };

  return (
    <Row key={stringKey} id={stringKey} className="mb-2" style={{ backgroundColor: '#eaeaea', border: 'none' }}>
      <Col md={2}>
        <Badge bg="info">{stringKey}</Badge>
      </Col>
      <Col xs={4} md={2}>
        <Form.Check
          id={`enabled_${stringKey}`}
          type="checkbox"
          checked={enabled ? 'checked' : ''}
          label="Enabled"
          name="enabled"
          onChange={onEnable}
          className="align-middle"
          inline
          disabled={readOnly}
        />
      </Col>
    </Row>
  );
};

const mapPublishTargetData = (projectsPublishTargetsData) => {
  const publishTargetData = {};

  projectsPublishTargetsData.projectsPublishTargets.forEach((publishTarget) => {
    const { stringKey, enabled } = publishTarget;

    publishTargetData[stringKey] = { enabled };
  });
  return publishTargetData;
};

export const PublishTargetsForm = ({ readOnly, projectStringKey }) => {
  const history = useHistory();

  const [projectPublishTargets, setProjectPublishTargets] = useState({});

  const variables = { stringKey: projectStringKey };

  const {
    loading: projectsPublishTargetsLoading,
    error: projectsPublishTargetsError,
    data: projectsPublishTargetsData,
  } = useQuery(getProjectsPublishTargetsQuery, { variables });

  useEffect(() => {
    if (projectsPublishTargetsLoading === false && projectsPublishTargetsData) {
      const mappedQueryData = mapPublishTargetData(projectsPublishTargetsData);
      setProjectPublishTargets(mappedQueryData);
    }
  }, [projectsPublishTargetsLoading, projectsPublishTargetsData]);

  const [updateEnabledPublishTargets, { error: updateError }] = useMutation(updateProjectsPublishTargetsMutation);

  if (projectsPublishTargetsLoading) return (<></>);

  if (projectsPublishTargetsError || updateError) {
    return (<GraphQLErrors errors={projectsPublishTargetsError || updateError} />);
  }

  const onSubmitHandler = () => {
    const enabledPublishTargetsArray = [];

    Object.entries(projectPublishTargets).forEach((entry) => {
      const [stringKey, data] = entry;

      if (data.enabled) {
        enabledPublishTargetsArray.push({ stringKey });
      }
    });

    const input = {
      project: { stringKey: projectStringKey },
      publishTargets: enabledPublishTargetsArray,
    };
    return updateEnabledPublishTargets({ variables: { input } });
  };

  const saveSuccessHandler = () => {
    history.push(`/projects/${projectStringKey}/publish_targets`);
  };

  const enabledDataCallback = (publishTargetStringKey, data) => {
    if (data) {
      const { enabled } = data;
      setProjectPublishTargets(produce(projectPublishTargets, (draft) => { draft[publishTargetStringKey] = { enabled }; }));
    }
    return projectPublishTargets[publishTargetStringKey];
  };

  return (
    <Form>
      {
        Object.entries(projectPublishTargets).map(([stringKey, data]) => (
          <PublishTarget
            key={stringKey}
            stringKey={stringKey}
            enabled={data.enabled}
            enabledDataCallback={enabledDataCallback}
            readOnly={readOnly}
          />
        ))
      }
      {
        !readOnly && (
          <FormButtons
            formType="edit"
            cancelTo={`/projects/${projectStringKey}/publish_targets`}
            onSave={onSubmitHandler}
            onSaveSuccess={saveSuccessHandler}
          />
        )
      }
    </Form>
  );
};

PublishTargetsForm.defaultProps = {
  readOnly: false,
};

PublishTargetsForm.propTypes = {
  readOnly: PropTypes.bool,
  projectStringKey: PropTypes.string.isRequired,
};

PublishTarget.propTypes = {
  stringKey: PropTypes.string.isRequired,
  enabled: PropTypes.bool.isRequired,
  enabledDataCallback: PropTypes.func.isRequired,
  readOnly: PropTypes.bool.isRequired,
};

export default PublishTargetsForm;
