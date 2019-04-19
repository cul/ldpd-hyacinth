import React from 'react';
import { Link } from "react-router-dom";
import { Table } from "react-bootstrap";
import producer from "immer";

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';

export default class FieldSetIndex extends React.Component {
  state = {
    fieldSets: []
  }

  componentDidMount() {
    hyacinthApi.get('/projects/' + this.props.match.params.string_key + '/field_sets')
      .then(res => {
        this.setState(producer(draft => { draft.fieldSets = res.data.field_sets }))
      }); // TODO: catch error
  }

  render() {
    let rows = this.state.fieldSets.map(field_set => {
      return (
        <tr key={field_set.id}>
          <td><Link to={"/projects/" + this.props.match.params.string_key + "/field_sets/" + field_set.id} className="nav-link" href="#">{field_set.display_label}</Link></td>
          <td></td>
        </tr>
      )
    })

    return(
      <div>
        <Table striped>
          <thead>
            <tr>
              <th>Field Set Name</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {rows}
          </tbody>
        </Table>
      </div>
    )
  }
}
