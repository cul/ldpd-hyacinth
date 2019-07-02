import React from 'react';
import { Link } from 'react-router-dom';
import { Table, Button } from 'react-bootstrap';
import produce from 'immer';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { LinkContainer } from 'react-router-bootstrap';

import TabHeading from '../../ui/tabs/TabHeading';
import hyacinthApi from '../../../util/hyacinth_api';
import { Can } from '../../../util/ability_context';

export default class FieldSetIndex extends React.Component {
  state = {
    fieldSets: [],
  }

  componentDidMount() {
    const { match: { params: { projectStringKey } } } = this.props;

    hyacinthApi.get(`/projects/${projectStringKey}/field_sets`)
      .then((res) => {
        this.setState(produce((draft) => { draft.fieldSets = res.data.fieldSets; }));
      });
  }

  render() {
    let rows = <tr><td colSpan="2">No fieldsets have been defined</td></tr>;

    const { match: { params: { projectStringKey } } } = this.props;
    const { fieldSets } = this.state;

    if (fieldSets.length > 0) {
      rows = fieldSets.map(fieldSet => (
        <tr key={fieldSet.id}>
          <td>
            <Can I="edit" of={{ subjectType: 'FieldSet', project: { stringKey: projectStringKey } }} passThrough>
              {
                  can => (
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
      <>
        <TabHeading>Field Sets</TabHeading>

        <Table hover>
          <tbody>
            {rows}

            <Can I="FieldSet" of={{ subjectType: 'FieldSet', project: { stringKey: projectStringKey } }}>
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
