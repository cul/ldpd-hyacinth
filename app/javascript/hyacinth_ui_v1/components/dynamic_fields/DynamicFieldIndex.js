import React from 'react';
import { Link } from 'react-router-dom';
import { Table, Card } from 'react-bootstrap';
import producer from 'immer';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import ContextualNavbar from '../layout/ContextualNavbar';
import hyacinthApi from '../../util/hyacinth_api';
import DynamicFieldsAndGroupsTable from '../layout/dynamic_fields/DynamicFieldsAndGroupsTable';

export default class DynamicFieldIndex extends React.Component {
  state = {
    dynamicFieldHierarchy: []
  }

  componentDidMount() {
    hyacinthApi.get('/dynamic_field_categories')
      .then((res) => {
        this.setState(producer((draft) => { draft.dynamicFieldHierarchy = res.data.dynamicFieldCategories; }));
      });
  }

  renderCategories() {
    return (
      this.state.dynamicFieldHierarchy.map(dynamicFieldCategory => {
        const { id, displayLabel, dynamicFieldGroups } = dynamicFieldCategory;

        return (
          <Card className="mb-3" key={id}>
            <Card.Header as="h5">
              {displayLabel} <Link to={`/dynamic_field_categories/${id}/edit`}><FontAwesomeIcon icon="pen" /></Link>
              <span className="badge badge-secondary float-right">Category</span>
            </Card.Header>
            <Card.Body>
              <DynamicFieldsAndGroupsTable rows={dynamicFieldGroups} />

              <Card.Text className="text-center">
                <Link to={`/dynamic_field_groups/new?parentType=DynamicFieldCategory&parentId=${id}`} href="#">
                  <FontAwesomeIcon icon="plus" />   New Dynamic Field Group
                </Link>
              </Card.Text>
            </Card.Body>
          </Card>
        )}
      )
    )
  }

  render() {
    return (
      <>
        <ContextualNavbar
          title="Dynamic Fields"
          rightHandLinks={[{ link: '/dynamic_field_categories/new', label: 'New Dynamic Field Category' }]}
        />

        {this.renderCategories()}
      </>
    )
  }
}
