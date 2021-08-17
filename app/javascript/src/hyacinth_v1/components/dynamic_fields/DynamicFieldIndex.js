import React from 'react';
import { Link } from 'react-router-dom';
import { Card } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import ContextualNavbar from '../shared/ContextualNavbar';
import GraphQLErrors from '../shared/GraphQLErrors';
import DynamicFieldsAndGroupsTable from '../shared/dynamic_fields/DynamicFieldsAndGroupsTable';
import EditButton from '../shared/buttons/EditButton';
import { getDynamicFieldCategoriesQuery } from '../../graphql/dynamicFieldCategories';
import FontAwesomeIcon from '../../utils/lazyFontAwesome';

function DynamicFieldIndex() {
  const {
    loading, error, data, refetch,
  } = useQuery(
    getDynamicFieldCategoriesQuery,
    { variables: { metadataForm: 'DESCRIPTIVE' } },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <>
      <ContextualNavbar
        title="Dynamic Fields"
        rightHandLinks={[{ link: '/dynamic_field_categories/new', label: 'New Dynamic Field Category' }]}
      />
      {
        data && data.dynamicFieldCategories.map((cat) => (
          <Card className="mb-3" key={cat.id} id={cat.displayLabel.replace(' ', '-')}>
            <Card.Header as="h5" className="text-center p-2">
              <span className="badge bg-primary float-start">Category</span>
              {cat.displayLabel}
              <EditButton className="float-end" link={`/dynamic_field_categories/${cat.id}/edit`} />
            </Card.Header>
            <Card.Body>
              <DynamicFieldsAndGroupsTable rows={cat.children} onChange={refetch} />
            </Card.Body>
            <Card.Text className="text-center">
              <Link to={`/dynamic_field_groups/new?parentType=DynamicFieldCategory&parentId=${cat.id}`}>
                <FontAwesomeIcon icon="plus" />
                {' New Dynamic Field Group'}
              </Link>
            </Card.Text>
          </Card>
        ))
      }
    </>
  );
}

export default DynamicFieldIndex;
