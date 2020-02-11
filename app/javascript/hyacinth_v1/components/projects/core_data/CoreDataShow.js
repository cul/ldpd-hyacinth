import React from 'react';
import { Row, Col } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';
import { useParams } from 'react-router-dom';

import TabHeading from '../../shared/tabs/TabHeading';
import { Can } from '../../../utils/abilityContext';
import EditButton from '../../shared/buttons/EditButton';
import { getProjectQuery } from '../../../graphql/projects';
import ProjectInterface from '../ProjectInterface';
import GraphQLErrors from '../../shared/GraphQLErrors';

function CoreDataShow() {
  const { stringKey } = useParams();
  const { loading, error, data } = useQuery(getProjectQuery, { variables: { stringKey } });

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <ProjectInterface project={data.project}>
      <TabHeading>
        Core Data
        <Can I="update" of={{ subjectType: 'Project', stringKey: data.project.stringKey }}>
          <EditButton
            className="float-right"
            size="lg"
            link={`/projects/${data.project.stringKey}/core_data/edit`}
          />
        </Can>
      </TabHeading>

      <Row as="dl">
        <Col as="dt" sm={2}>String Key</Col>
        <Col as="dd" sm={10}>{data.project.stringKey}</Col>

        <Col as="dt" sm={2}>Display Label</Col>
        <Col as="dd" sm={10}>{data.project.displayLabel}</Col>

        <Col as="dt" sm={2}>Is Primary</Col>
        <Col as="dd" sm={10}>{data.project.isPrimary.toString()}</Col>

        <Col as="dt" sm={2}>Asset Rights</Col>
        <Col as="dd" sm={10}>{data.project.hasAssetRights.toString()}</Col>

        <Col as="dt" sm={2}>Project URL</Col>
        <Col as="dd" sm={10}>{data.project.projectUrl}</Col>
      </Row>
    </ProjectInterface>
  );
}

export default CoreDataShow;
