import { useQuery } from '@apollo/react-hooks';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import React from 'react';
import { Table } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { publishTargetsQuery } from '../../graphql/publishTargets';
import ContextualNavbar from '../shared/ContextualNavbar';
import GraphQLErrors from '../shared/GraphQLErrors';


function PublishTargetIndex() {
  const { loading, error, data } = useQuery(publishTargetsQuery);

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <>
      <ContextualNavbar
        title="Publish Targets"
        rightHandLinks={[{ link: '/publish_targets/new', label: 'New Publish Target' }]}
      />

      <Table hover responsive>
        <thead>
          <tr>
            <th>String Key</th>
            <th>Publish URL</th>
            <th>Allowed DOI Target?</th>
            <th>DOI Priority</th>
            <th className="text-center">Actions</th>
          </tr>
        </thead>
        <tbody>
          {
            data && (
              data.publishTargets.map(publishTarget => (
                <tr key={publishTarget.stringKey}>
                  <td>{publishTarget.stringKey}</td>
                  <td>{publishTarget.publishUrl}</td>
                  <td>{`${publishTarget.isAllowedDoiTarget}`}</td>
                  <td>{publishTarget.isAllowedDoiTarget ? publishTarget.doiPriority : ''}</td>
                  <td className="text-center">
                    <Link to={`/publish_targets/${publishTarget.stringKey}`} className="btn btn-secondary btn-sm mx-1">
                      <FontAwesomeIcon icon="eye" />
                    </Link>
                    <Link to={`/publish_targets/${publishTarget.stringKey}/edit`} className="btn btn-secondary btn-sm mx-1">
                      <FontAwesomeIcon icon="pen" />
                    </Link>
                  </td>
                </tr>
              ))
            )
          }
        </tbody>
      </Table>
    </>
  );
}

export default PublishTargetIndex;
