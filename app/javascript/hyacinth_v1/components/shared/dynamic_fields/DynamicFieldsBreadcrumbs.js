import React from 'react';
import { LinkContainer } from 'react-router-bootstrap';
import { Breadcrumb } from 'react-bootstrap';
import produce from 'immer';

import hyacinthApi from '../../../util/hyacinth_api';

class DynamicFieldsBreadcrumbs extends React.Component {
  state = {
    dynamicFieldGraph: [],
  }

  componentDidMount() {
    hyacinthApi.get('/dynamic_field_categories')
      .then((res) => {
        this.setState(produce((draft) => {
          draft.dynamicFieldGraph = res.data.dynamicFieldCategories;
        }));
      });
  }

  findPath(dynamicFieldHierarchy, seekId, seekType) {
    const {
      id, type, displayLabel, children,
    } = dynamicFieldHierarchy;

    if (id === seekId && type === seekType) {
      return [{ id, type, displayLabel }];
    } if (children && children.length !== 0) {
      for (const child of children) {
        const foundPath = this.findPath(child, seekId, seekType);
        if (foundPath !== null) {
          return [{ id, type, displayLabel }].concat(foundPath);
        }
      }
    }

    return null;
  }

  render() {
    const { for: { id: stringId, type }, last } = this.props;

    let id = parseInt(stringId);

    let path = [];
    for (const category of this.state.dynamicFieldGraph) {
      const foundPath = this.findPath(category, id, type);
      if (foundPath != null) {
        path = foundPath;
        break;
      }
    }

    const crumbs = path.map((segment, index) => (
      <LinkContainer
        to={segment.type === 'DynamicFieldCategory' ? '/dynamic_fields' : `/dynamic_field_groups/${segment.id}/edit`}
      >
        <Breadcrumb.Item active={!last && index === path.length - 1}>
          {segment.displayLabel}
        </Breadcrumb.Item>
      </LinkContainer>
    ));

    return (
      <Breadcrumb>
        {crumbs}
        {
          last && (
            <Breadcrumb.Item active>{last}</Breadcrumb.Item>
          )
        }
      </Breadcrumb>
    );
  }
}

export default DynamicFieldsBreadcrumbs;
