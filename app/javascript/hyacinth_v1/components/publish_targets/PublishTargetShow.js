import { useQuery } from '@apollo/react-hooks';
import React from 'react';
import { Col, Row } from 'react-bootstrap';
import { useParams } from 'react-router-dom';

import { publishTargetQuery } from '../../graphql/publishTargets';
import ContextualNavbar from '../shared/ContextualNavbar';
import GraphQLErrors from '../shared/GraphQLErrors';

function PublishTargetEdit() {
  const { stringKey } = useParams();

  const { loading, error, data } = useQuery(publishTargetQuery, { variables: { stringKey } });

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { publishTarget } = data;

  return (
    <>
      <ContextualNavbar
        title="View Publish Target"
        rightHandLinks={[
          { link: `/publish_targets/${publishTarget.stringKey}/edit`, label: 'Edit' },
          { link: '/publish_targets', label: 'Back to All Publish Targets' },
        ]}
      />

      <Row as="dl">
        <Col as="dt" sm={4}>String Key</Col>
        <Col as="dd" sm={8}>{publishTarget.stringKey}</Col>

        <Col as="dt" sm={4}>Publish URL</Col>
        <Col as="dd" sm={8}>{publishTarget.publishUrl}</Col>

        <Col as="dt" sm={4}>API Key</Col>
        <Col as="dd" sm={8}>{publishTarget.apiKey}</Col>

        <Col as="dt" sm={4}>Allowed to be set as DOI target?</Col>
        <Col as="dd" sm={8}>{`${publishTarget.isAllowedDoiTarget}`}</Col>

        <Col as="dt" sm={4}>DOI Priority</Col>
        <Col as="dd" sm={8}>{publishTarget.doiPriority}</Col>
      </Row>
    </>
  );
}

export default PublishTargetEdit;
