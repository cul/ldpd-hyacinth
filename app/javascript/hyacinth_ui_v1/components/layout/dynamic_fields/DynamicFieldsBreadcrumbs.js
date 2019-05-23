import React from 'react';
import { LinkContainer } from 'react-router-bootstrap';
import { Breadcrumb } from 'react-bootstrap';
import produce from 'immer';

import hyacinthApi from '../../../util/hyacinth_api';

class DynamicFieldsBreadcrumbs extends React.Component {
  state = {
    dynamicFieldGraph: []
  }

  componentDidMount() {
    hyacinthApi.get('/dynamic_field_categories')
      .then((res) => {
        this.setState(produce((draft) => { draft.dynamicFieldGraph = res.data.dynamicFieldCategories; }));
      });
  }

  findPath(dynamicFieldHierarchy, seekId, seekType) {
    const { id, type, displayLabel, children } = dynamicFieldHierarchy;

    if (id === seekId && type == seekType){
      return [{ id: id, type: type, displayLabel: displayLabel }]
    } else if (children && children.length !== 0) {
      for (let child of children) {
        let foundPath = this.findPath(child, seekId, seekType)
        if (foundPath !== null) {
          return [{ id: id, type: type, displayLabel: displayLabel  }].concat(foundPath)
        }
      }
    }

    return null;
  }

  render() {
    let { for: { id, type }, last } = this.props;

    id = parseInt(id);

    console.log(this.props);

    let path = [];
    for (let category of this.state.dynamicFieldGraph) {
      let foundPath = this.findPath(category, id, type)
      console.log(foundPath)
      if (foundPath != null){
        path = foundPath;
        break;
      }
    }

    console.log(path);

    const crumbs = path.map((segment, index) => (
      <LinkContainer to={segment.type === 'DynamicFieldCategory' ? '/dynamic_fields': `/dynamic_field_groups/${segment.id}/edit`}>
        <Breadcrumb.Item active={!last && index === path.length-1}>{segment.displayLabel}</Breadcrumb.Item>
      </LinkContainer>
    ));

    return (
      <Breadcrumb style={{backgroundColor: '#f3f7fb'}}>
        {crumbs}
        {
          last && (
            <Breadcrumb.Item active>{last}</Breadcrumb.Item>
          )
        }
      </Breadcrumb>
    )
  }
}

export default DynamicFieldsBreadcrumbs;
