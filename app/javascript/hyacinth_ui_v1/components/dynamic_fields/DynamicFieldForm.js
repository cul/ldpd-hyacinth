import React from 'react';
import { Row, Form, Collapse } from 'react-bootstrap';
import produce from 'immer';
import { startCase } from 'lodash';
import { withRouter } from 'react-router-dom';

import hyacinthApi from '../../util/hyacinth_api';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';
import InputGroup from '../ui/forms/InputGroup';
import Label from '../ui/forms/Label';
import FormButtons from '../ui/forms/FormButtons';
import TextInput from '../ui/forms/inputs/TextInput';
import NumberInput from '../ui/forms/inputs/NumberInput';
import JSONInput from '../ui/forms/inputs/JSONInput';
import SelectInput from '../ui/forms/inputs/SelectInput';
import Checkbox from '../ui/forms/inputs/Checkbox';

const fieldTypes = [
  'string', 'textarea', 'integer', 'boolean', 'select', 'date', 'controlled_term',
];

class DynamicFieldForm extends React.Component {
  state = {
    vocabularies: [],
    formType: '',
    dynamicField: {
      stringKey: '',
      displayLabel: '',
      fieldType: 'string',
      sortOrder: '',
      isFacetable: false,
      filterLabel: '',
      controlledVocabulary: '',
      selectOptions: '{}',
      isKeywordSearchable: false,
      isTitleSearchable: false,
      isIdentifierSearchable: false,
      dynamicFieldGroupId: '',
    },
  }

  componentDidMount() {
    const { id, formType, defaultValues } = this.props;

    if (formType === 'edit' && id) {
      hyacinthApi.get(`/dynamic_fields/${id}`)
        .then((res) => {
          const { dynamicField } = res.data;

          this.setState(produce((draft) => {
            draft.formType = formType;
            draft.dynamicField = dynamicField;
          }));
        });
    } else if (formType === 'new') {
      const { dynamicFieldGroupId } = defaultValues;

      this.setState(produce((draft) => {
        draft.formType = 'new';
        draft.dynamicField.dynamicFieldGroupId = dynamicFieldGroupId;
      }));
    }

    hyacinthApi.get('vocabularies')
      .then((res) => {
        const { vocabularies } = res.data;

        this.setState(produce((draft) => {
          draft.vocabularies = vocabularies.map(v => ({ value: v.stringKey, label: v.label }));
        }));
      });
  }

  onSave = () => {
    const { formType, dynamicField: { id }, dynamicField } = this.state;
    const { history: { push } } = this.props;

    switch (formType) {
      case 'new':
        return hyacinthApi.post('/dynamic_fields', dynamicField)
          .then((res) => {
            const { dynamicField: { id: newId } } = res.data;

            push(`/dynamic_fields/${newId}/edit`);
          });
      case 'edit':
        return hyacinthApi.patch(`/dynamic_fields/${id}`, dynamicField);
      default:
        return null;
    }
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const { dynamicField: { id } } = this.state;
    const { history: { push } } = this.props;

    hyacinthApi.delete(`/dynamic_fields/${id}`)
      .then(() => push('/dynamic_fields'));
  }

  onChange(name, value) {
    this.setState(produce((draft) => {
      draft.dynamicField[name] = value;
    }));
  }

  render() {
    const {
      formType,
      vocabularies,
      dynamicField: {
        stringKey,
        displayLabel,
        filterLabel,
        selectOptions,
        isFacetable,
        sortOrder,
        fieldType,
        controlledVocabulary,
        isKeywordSearchable,
        isTitleSearchable,
        isIdentifierSearchable,
      },
    } = this.state;

    return (
      <Form onSubmit={this.onSubmitHandler}>
        <InputGroup>
          <Label>String Key</Label>
          <TextInput
            value={stringKey}
            onChange={v => this.onChange('stringKey', v)}
            disabled={formType === 'edit'}
          />
        </InputGroup>

        <InputGroup>
          <Label>Display Label</Label>
          <TextInput value={displayLabel} onChange={v => this.onChange('displayLabel', v)} />
        </InputGroup>

        <InputGroup>
          <Label>Sort Order</Label>
          <NumberInput value={sortOrder} onChange={v => this.onChange('sortOrder', v)} />
        </InputGroup>

        <h4>Field Configuration</h4>

        <InputGroup as={Row}>
          <Label>Field Type</Label>
          <SelectInput
            value={fieldType}
            options={fieldTypes.map(t => ({ value: t, label: startCase(t) }))}
            onChange={v => this.onChange('fieldType', v)}
          />
        </InputGroup>

        <Collapse in={fieldType === 'controlled_term'}>
          <div>
            <InputGroup>
              <Label>Controlled Vocabulary</Label>
              <SelectInput
                value={controlledVocabulary}
                options={vocabularies}
                onChange={v => this.onChange('controlledVocabulary', v)}
              />
            </InputGroup>
          </div>
        </Collapse>

        <Collapse in={fieldType === 'select'}>
          <div>
            <InputGroup>
              <Label>Select Options</Label>
              <JSONInput
                value={selectOptions}
                onChange={v => this.onChange('selectOptions', v)}
                height="100px"
                placeholder={'[{ "option": "label" }]'}
              />
            </InputGroup>
          </div>
        </Collapse>

        <h4>Searching/Facets</h4>
        <InputGroup>
          <Label>Filter Label</Label>
          <TextInput value={filterLabel} onChange={v => this.onChange('filterLabel', v)} />
        </InputGroup>

        <InputGroup>
          <Label>Is Facetable?</Label>
          <Checkbox
            value={isFacetable}
            onChange={v => this.onChange('isFacetable', v)}
          />
        </InputGroup>

        <InputGroup>
          <Label>Include in:</Label>
          <Checkbox
            sm={3}
            lg={2}
            value={isKeywordSearchable}
            onChange={v => this.onChange('isKeywordSearchable', v)}
            label="keyword search"
          />
          <Checkbox
            sm={3}
            lg={2}
            value={isTitleSearchable}
            onChange={v => this.onChange('isTitleSearchable', v)}
            label="title search"
          />
          <Checkbox
            sm={3}
            lg={2}
            value={isIdentifierSearchable}
            onChange={v => this.onChange('isIdentifierSearchable', v)}
            label="identifier search"
          />
        </InputGroup>

        <FormButtons
          formType={formType}
          cancelTo="/dynamic_fields"
          onDelete={this.onDeleteHandler}
          onSave={this.onSave}
        />
      </Form>
    );
  }
}

export default withRouter(withErrorHandler(DynamicFieldForm, hyacinthApi));
