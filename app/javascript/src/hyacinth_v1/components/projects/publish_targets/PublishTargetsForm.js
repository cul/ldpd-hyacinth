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
import { getAvailablePublishTargetsQuery, updateProjectsPublishTargetsMutation } from '../../../graphql/projects/publishTargets';

const AvailablePublishTarget = (props) => {
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

const mapPublishTargetData = (availablePublishTargetsData) => {
  const publishTargetData = {};

  availablePublishTargetsData.project.availablePublishTargets.forEach((publishTarget) => {
    const { stringKey, enabled } = publishTarget;

    publishTargetData[stringKey] = { enabled };
  });
  return publishTargetData;
};

const PublishTargetsForm = ({ readOnly, projectStringKey }) => {
  const history = useHistory();

  const [availablePublishTargets, setAvailablePublishTargets] = useState({});

  const variables = { stringKey: projectStringKey };

  const {
    loading: availablePublishTargetsLoading,
    error: availablePublishTargetsError,
    data: availablePublishTargetsData,
  } = useQuery(getAvailablePublishTargetsQuery, { variables });

  useEffect(() => {
    if (availablePublishTargetsLoading === false && availablePublishTargetsData) {
      const mappedQueryData = mapPublishTargetData(availablePublishTargetsData);
      setAvailablePublishTargets(mappedQueryData);
    }
  }, [availablePublishTargetsLoading, availablePublishTargetsData]);

  const [updateEnabledPublishTargets, { error: updateError }] = useMutation(updateProjectsPublishTargetsMutation);

  if (availablePublishTargetsLoading) return (<></>);

  if (availablePublishTargetsError || updateError) {
    return (<GraphQLErrors errors={availablePublishTargetsError || updateError} />);
  }

  const onSubmitHandler = () => {
    const enabledPublishTargetsArray = [];

    Object.entries(availablePublishTargets).forEach((entry) => {
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
      setAvailablePublishTargets(produce(availablePublishTargets, (draft) => { draft[publishTargetStringKey] = { enabled }; }));
    }
    return availablePublishTargets[publishTargetStringKey];
  };

  return (
    <Form>
      {
        Object.entries(availablePublishTargets).map(([stringKey, data]) => (
          <AvailablePublishTarget
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

AvailablePublishTarget.propTypes = {
  stringKey: PropTypes.string.isRequired,
  enabled: PropTypes.bool.isRequired,
  enabledDataCallback: PropTypes.func.isRequired,
  readOnly: PropTypes.bool.isRequired,
};

export default PublishTargetsForm;
