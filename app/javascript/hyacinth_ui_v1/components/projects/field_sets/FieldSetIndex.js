import React from 'react';
import { Link } from 'react-router-dom';
import { Table, Button } from 'react-bootstrap';
import producer from 'immer';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { LinkContainer } from 'react-router-bootstrap';

import ProjectSubHeading from 'hyacinth_ui_v1/hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';
import { Can } from 'hyacinth_ui_v1/util/ability_context';

export default class FieldSetIndex extends React.Component {
  state = {
    fieldSets: [],
  }

  componentDidMount() {
    hyacinthApi.get(`/projects/${this.props.match.params.string_key}/field_sets`)
      .then((res) => {
        this.setState(producer((draft) => { draft.fieldSets = res.data.field_sets; }));
      }); // TODO: catch error
  }

  render() {
    let rows = <tr><td colSpan="2">No fieldsets have been defined</td></tr>;

    if (this.state.fieldSets.length > 0) {
      rows = this.state.fieldSets.map(fieldSet => (
        <tr key={fieldSet.id}>
          <td>
            <Can I="edit" of={{ modelName: 'FieldSet', project: { stringKey: this.props.match.params.string_key } }} passThrough>
              {
                  can => (
                    can
                      ? <Link to={`/projects/${this.props.match.params.string_key}/field_sets/${fieldSet.id}/edit`} href="#">{fieldSet.display_label}</Link>
                      : fieldSet.display_label
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
            <tr>
              <td className="text-center">
                <LinkContainer to={`${this.props.match.url}/new`}>
                  <Button size="sm" variant="link">
                    <FontAwesomeIcon icon="plus" />
                    {' '}
Add New Field Set
                  </Button>
                </LinkContainer>
              </td>
            </tr>
          </tbody>
        </Table>
      </>
    );
  }
}
