import React from 'react';
import queryString from 'query-string';

import ContextualNavbar from '../layout/ContextualNavbar';
import hyacinthApi from '../../util/hyacinth_api';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';
import DynamicFieldForm from './DynamicFieldForm';
import DynamicFieldsBreadcrumbs from '../layout/dynamic_fields/DynamicFieldsBreadcrumbs';

class DynamicFieldGroupNew extends React.Component {
  createDynamicFieldGroup = (data) => {
    hyacinthApi.post('/dynamic_fields', data)
      .then((res) => {
        const { dynamicField: { id } } = res.data;

        this.props.history.push(`/dynamic_fields/${id}/edit`);
      });
  }

  render() {
    const { location: { search } } = this.props;
    const { dynamicFieldGroupId } = queryString.parse(search);

    return (
      <>
        <ContextualNavbar
          title="Create Dynamic Field"
          rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
        />

        <DynamicFieldsBreadcrumbs
          for={{ id: dynamicFieldGroupId, type: 'DynamicFieldGroup' }}
          last="New Dynamic Field"
        />

        <DynamicFieldForm
          formType="new"
          defaultValues={{ dynamicFieldGroupId }}
        />
      </>
    );
  }
}

export default withErrorHandler(DynamicFieldGroupNew, hyacinthApi);
