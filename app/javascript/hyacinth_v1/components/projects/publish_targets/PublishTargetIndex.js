import React from 'react';
import { Table, Button } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { LinkContainer } from 'react-router-bootstrap';
import { useQuery } from '@apollo/react-hooks';
import { Link, useParams } from 'react-router-dom';

import TabHeading from '../../shared/tabs/TabHeading';
import { Can } from '../../../utils/abilityContext';
import ProjectInterface from '../ProjectInterface';
import GraphQLErrors from '../../shared/GraphQLErrors';
import { publishTargetsQuery } from '../../../graphql/publishTargets';

function PublishTargetIndex() {
  const { projectStringKey } = useParams();

  const { loading, error, data } = useQuery(
    publishTargetsQuery,
    { variables: { stringKey: projectStringKey } },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <ProjectInterface project={data.project}>
      <TabHeading>Publish Targets</TabHeading>

      <Table hover responsive>
        <thead>
          <tr>
            <th>Target Type</th>
            <th>String Identifier</th>
            <th>Publish URL</th>
          </tr>
        </thead>
        <tbody>
          {
            data.project.publishTargets && (
              data.project.publishTargets.map(publishTarget => (
                <tr key={publishTarget.combinedKey}>
                  <td>
                    <Can I="update" of={{ subjectType: 'PublishTarget', project: { stringKey: projectStringKey } }} passThrough>
                      {
                          can => (
                            can
                              ? <Link to={`/projects/${projectStringKey}/publish_targets/${publishTarget.type.toLowerCase()}/edit`}>{publishTarget.type.toLowerCase()}</Link>
                              : publishTarget.type
                          )
                        }
                    </Can>
                  </td>
                  <td>{publishTarget.combinedKey}</td>
                  <td>{publishTarget.publishUrl}</td>
                </tr>
              ))
            )
          }
          <Can I="create" of={{ subjectType: 'PublishTarget', project: { stringKey: projectStringKey } }}>
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
