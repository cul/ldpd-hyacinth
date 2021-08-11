import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';
import { LinkContainer } from 'react-router-bootstrap';
import { Breadcrumb } from 'react-bootstrap';
import { lowerFirst } from 'lodash';

import GraphQLErrors from '../GraphQLErrors';
import { dynamicFieldPathQuery } from '../../../graphql/dynamicFields';
import { dynamicFieldGroupPathQuery } from '../../../graphql/dynamicFieldGroups';
import { getDynamicFieldCategoryQuery } from '../../../graphql/dynamicFieldCategories';

const mappedQueries = {
  DynamicFieldGroup: dynamicFieldGroupPathQuery,
  DynamicField: dynamicFieldPathQuery,
  DynamicFieldCategory: getDynamicFieldCategoryQuery,
};

function DynamicFieldsBreadcrumbs(props) {
  const { for: { id, type }, last } = props;

  const { loading, error, data } = useQuery(
    mappedQueries[type], { variables: { id } },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { ancestorNodes, ...fieldOrGroupData } = data[lowerFirst(type)];
  const ancestorPathWithCurrent = (ancestorNodes || []).concat(fieldOrGroupData);

  return (
    <Breadcrumb>
      {
        ancestorPathWithCurrent.map((segment, index) => (
          <LinkContainer
            key={segment.id}
            to={segment.type === 'DynamicFieldCategory' ? '/dynamic_fields' : `/dynamic_field_groups/${segment.id}/edit`}
          >
            <Breadcrumb.Item active={!last && index === ancestorPathWithCurrent.length - 1}>
              {segment.displayLabel}
            </Breadcrumb.Item>
          </LinkContainer>
        ))
      }
      {
        last && (
          <Breadcrumb.Item active>{last}</Breadcrumb.Item>
        )
      }
    </Breadcrumb>
  );
}

DynamicFieldsBreadcrumbs.defaultProps = {
  for: null,
  last: null,
};

DynamicFieldsBreadcrumbs.propTypes = {
  for: PropTypes.shape({
    id: PropTypes.string.isRequired,
    type: PropTypes.oneOf(['DynamicFieldGroup', 'DynamicField', 'DynamicFieldCategory']).isRequired,
  }),
  last: PropTypes.string,
};

export default DynamicFieldsBreadcrumbs;
