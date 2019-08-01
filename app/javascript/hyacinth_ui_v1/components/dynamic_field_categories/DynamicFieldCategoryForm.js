import React from 'react';
import { Form } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import produce from 'immer';

import hyacinthApi from '../../util/hyacinth_api';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';
import FormButtons from '../ui/forms/FormButtons';
import InputGroup from '../ui/forms/InputGroup';
import Label from '../ui/forms/Label';
import NumberInput from '../ui/forms/inputs/NumberInput';
import TextInput from '../ui/forms/inputs/TextInput';

class DynamicFieldCategoryForm extends React.Component {
  state = {
    formType: '',
    dynamicFieldCategory: {
      displayLabel: '',
      sortOrder: '',
    },
  }

  componentDidMount() {
    const { formType, id } = this.props;

    if (id) {
      hyacinthApi.get(`/dynamic_field_categories/${id}`)
        .then((res) => {
          const { dynamicFieldCategory } = res.data;

          this.setState(produce((draft) => {
            draft.dynamicFieldCategory = dynamicFieldCategory;
          }));
        });
    }

    this.setState(produce((draft) => {
      draft.formType = formType;
    }));
  }

  onSubmitHandler = () => {
    const { formType, dynamicFieldCategory: { id }, dynamicFieldCategory } = this.state;
    const { history: { push } } = this.props;

    switch (formType) {
      case 'new':
        return hyacinthApi.post('/dynamic_field_categories', dynamicFieldCategory)
          .then((res) => {
            const { dynamicFieldCategory: { id: newId } } = res.data;

            push(`/dynamic_field_categories/${newId}/edit`);
          });
      case 'edit':
        return hyacinthApi.patch(`/dynamic_field_categories/${id}`, dynamicFieldCategory);
      default:
        return null;
    }
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const { dynamicFieldCategory: { id } } = this.state;

    hyacinthApi.delete(`/dynamic_field_categories/${id}`)
      .then(() => {
        this.props.history.push('/dynamic_fields');
      });
  }

  onChange(name, value) {
    this.setState(produce((draft) => {
      draft.dynamicFieldCategory[name] = value;
    }));
  }

  render() {
    const { formType, dynamicFieldCategory: { displayLabel, sortOrder } } = this.state;

    return (
      <Form onSubmit={this.onSubmitHandler}>
        <InputGroup>
          <Label>Display Label</Label>
          <TextInput
            value={displayLabel}
            onChange={v => this.onChange('displayLabel', v)}
          />
        </InputGroup>

        <InputGroup>
          <Label>Sort Order</Label>
          <NumberInput
            value={sortOrder}
            onChange={v => this.onChange('sortOrder', v)}
          />
        </InputGroup>

        <FormButtons
          formType={formType}
          cancelTo="/dynamic_fields"
          onDelete={this.onDeleteHandler}
          onSave={this.onSubmitHandler}
        />
      </Form>
    );
  }
}

export default withRouter(withErrorHandler(DynamicFieldCategoryForm, hyacinthApi));
