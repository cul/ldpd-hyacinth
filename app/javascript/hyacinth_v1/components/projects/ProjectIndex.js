import React from 'react';
import { Link } from 'react-router-dom';
import { Table } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import ContextualNavbar from '../shared/ContextualNavbar';
import { Can } from '../../utils/abilityContext';
import { getProjectsQuery } from '../../graphql/projects';
import GraphQLErrors from '../shared/GraphQLErrors';

function ProjectIndex() {
  const { loading, error, data } = useQuery(getProjectsQuery);

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <>
      <Can I="create" a="Project" passThrough>
        {
          can => (
            <ContextualNavbar
              title="Projects"
              rightHandLinks={can ? [{ link: '/projects/new', label: 'New Project' }] : []}
            />
          )
        }
      </Can>

      <Table hover responsive>
        <thead>
          <tr>
            <th>Display Label</th>
            <th>String Key</th>
            <th>Primary?</th>
            <th>Asset Rights?</th>
            <th>Download Template Header</th>
          </tr>
        </thead>
        <tbody>
          {
            data && (
              data.projects.map(project => (
                <tr key={project.stringKey}>
                  <td><Link to={`/projects/${project.stringKey}/core_data`}>{project.displayLabel}</Link></td>
                  <td>{project.stringKey}</td>
                  <td>{project.isPrimary ? 'true' : ''}</td>
                  <td>{project.hasAssetRights ? 'true' : ''}</td>
                  <td />
                </tr>
              ))
            )
          }
        </tbody>
      </Table>
    </>
  );
}

export default ProjectIndex;
