import React from 'react';
import { Link } from 'react-router-dom';
import { Table, Button } from 'react-bootstrap';
import producer from 'immer';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { LinkContainer } from 'react-router-bootstrap';

import ProjectSubHeading from '../../../hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import hyacinthApi from '../../../util/hyacinth_api';
import { Can } from '../../../util/ability_context';

export default class FieldSetIndex extends React.Component {
  state = {
    fieldSets: [],
  }

  componentDidMount() {
    const { projectStringKey } = this.props.match.params

    hyacinthApi.get(`/projects/${projectStringKey}/field_sets`)
      .then((res) => {
        this.setState(producer((draft) => { draft.fieldSets = res.data.fieldSets; }));
      }); // TODO: catch error
  }

  render() {
    let rows = <tr><td colSpan="2">No fieldsets have been defined</td></tr>;

    const { projectStringKey } = this.props.match.params

    if (this.state.fieldSets.length > 0) {
      rows = this.state.fieldSets.map(fieldSet => (
        <tr key={fieldSet.id}>
          <td>
            <Can I="edit" of={{ subjectType: 'FieldSet', project: { stringKey: projectStringKey } }} passThrough>
              {
                  can => (
                    can
                      ? <Link to={`/projects/${projectStringKey}/field_sets/${fieldSet.id}/edit`} href="#">{fieldSet.displayLabel}</Link>
                      : fieldSet.displayLabel
                  )
                }
            </Can>
          </td>
        </tr>
      ));
    }

    return (
      <>
        <ProjectSubHeading>Field Sets</ProjectSubHeading>

        <Table hover>
          <tbody>
            {rows}

            <Can I="FieldSet" of={{ subjectType: 'FieldSet', project: { stringKey: this.props.match.params.projectStringKey } }} >
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
      </>
    );
  }
}
