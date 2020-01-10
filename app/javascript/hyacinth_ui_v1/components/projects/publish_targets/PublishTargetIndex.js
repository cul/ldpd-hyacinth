import React from 'react';
import { Table, Button } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { LinkContainer } from 'react-router-bootstrap';
import { useQuery } from '@apollo/react-hooks';
import { Link, useParams } from 'react-router-dom';
import { gql } from 'apollo-boost';

import TabHeading from '../../ui/tabs/TabHeading';
import { Can } from '../../../util/ability_context';
import ProjectInterface from '../ProjectInterface';
import GraphQLErrors from '../../ui/GraphQLErrors';

const PROJECT_WITH_PUBLISH_TARGETS = gql`
  query Project($stringKey: ID!){
    project(stringKey: $stringKey) {
      stringKey
      displayLabel
      publishTargets {
        stringKey
        displayLabel
        publishUrl
        apiKey
      }
    }
  }
`;

function PublishTargetIndex() {
  const { projectStringKey } = useParams();

  const { loading, error, data } = useQuery(
    PROJECT_WITH_PUBLISH_TARGETS,
    { variables: { stringKey: projectStringKey } },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <ProjectInterface project={data.project}>
      <TabHeading>Publish Targets</TabHeading>

      <Table hover>
        <thead>
          <tr>
            <th>Display Label</th>
            <th>String Key</th>
            <th>Publish URL</th>
          </tr>
        </thead>
        <tbody>
          {
            data.project.publishTargets && (
              data.project.publishTargets.map(publishTarget => (
                <tr key={publishTarget.stringKey}>
                  <td>
                    <Can I="edit" of={{ subjectType: 'PublishTarget', project: { stringKey: projectStringKey } }} passThrough>
                      {
                          can => (
                            can
                              ? <Link to={`/projects/${projectStringKey}/publish_targets/${publishTarget.stringKey}/edit`}>{publishTarget.displayLabel}</Link>
                              : publishTarget.displayLabel
                          )
                        }
                    </Can>
                  </td>
                  <td>{publishTarget.stringKey}</td>
                  <td>{publishTarget.publishUrl}</td>
                  <td>{publishTarget.apiKey}</td>
                </tr>
              ))
            )
          }
          <Can I="PublishTarget" of={{ subjectType: 'FieldSet', project: { stringKey: projectStringKey } }}>
            <tr>
              <td className="text-center" colSpan="4">
                <LinkContainer to={`/projects/${projectStringKey}/publish_targets/new`}>
                  <Button size="sm" variant="link">
                    <FontAwesomeIcon icon="plus" />
                    {' '}
Add New Publish Target
                  </Button>
                </LinkContainer>
              </td>
            </tr>
          </Can>
        </tbody>
      </Table>
    </ProjectInterface>
  );
}

export default PublishTargetIndex;
