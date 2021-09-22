import React from 'react';
import { Table, Button } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';
import gql from 'graphql-tag';
import { useQuery } from '@apollo/react-hooks';
import { Link, useParams } from 'react-router-dom';

import TabHeading from '../../shared/tabs/TabHeading';
import { Can } from '../../../utils/abilityContext';
import FontAwesomeIcon from '../../../utils/lazyFontAwesome';
import ProjectInterface from '../ProjectInterface';
import GraphQLErrors from '../../shared/GraphQLErrors';

const PROJECT_WITH_FIELD_SETS = gql`
  query Project($stringKey: ID!){
    project(stringKey: $stringKey) {
      stringKey
      displayLabel
      fieldSets {
        id
        displayLabel
      }
    }
  }
`;

function FieldSetIndex() {
  const { projectStringKey } = useParams();

  const { loading, error, data } = useQuery(
    PROJECT_WITH_FIELD_SETS,
    { variables: { stringKey: projectStringKey } },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  let rows = <tr><td colSpan="2">No fieldsets have been defined</td></tr>;

  if (data.project.fieldSets.length > 0) {
    rows = data.project.fieldSets.map((fieldSet) => (
      <tr key={fieldSet.id}>
        <td>
          <Can I="update" of={{ subjectType: 'FieldSet', project: { stringKey: projectStringKey } }} passThrough>
            {
                (can) => (
                  can
                    ? <Link to={`/projects/${projectStringKey}/field_sets/${fieldSet.id}/edit`}>{fieldSet.displayLabel}</Link>
                    : fieldSet.displayLabel
                )
              }
          </Can>
        </td>
      </tr>
    ));
  }

  return (
    <ProjectInterface project={data.project}>
      <TabHeading>Field Sets</TabHeading>
      <Table hover responsive>
        <tbody>
          {rows}

          <Can I="create" of={{ subjectType: 'FieldSet', project: { stringKey: projectStringKey } }}>
            <tr>
              <td className="text-center">
                <LinkContainer to={`/projects/${projectStringKey}/field_sets/new`}>
                  <Button size="sm" variant="link">
                    <FontAwesomeIcon icon="plus" />
                    {' '}
                    Add New Field Set
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

export default FieldSetIndex;
