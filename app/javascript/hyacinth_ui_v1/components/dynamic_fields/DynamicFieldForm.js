import React from 'react';
import { Row, Col, Form } from 'react-bootstrap';
import produce from 'immer';
import { startCase } from 'lodash';
import { withRouter } from 'react-router-dom';

import CancelButton from '../layout/forms/CancelButton';
import DeleteButton from '../layout/forms/DeleteButton';
import SubmitButton from '../layout/forms/SubmitButton';
import hyacinthApi from '../../util/hyacinth_api';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';

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
          draft.vocabularies = vocabularies.map(v => ({ stringKey: v.stringKey, label: v.label }));
        }));
      });
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const { formType, dynamicField: { id }, dynamicField } = this.state;
    const { history: { push } } = this.props;

    switch (formType) {
      case 'new':
        hyacinthApi.post('/dynamic_fields', dynamicField)
          .then((res) => {
            const { dynamicField: { id: newId } } = res.data;

            push(`/dynamic_fields/${newId}/edit`);
          });
        break;
      case 'edit':
        hyacinthApi.patch(`/dynamic_fields/${id}`, dynamicField)
          .then(() => push(`/dynamic_fields/${id}/edit`));
        break;
      default:
        break;
    }
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const { dynamicField: { id } } = this.state;
    const { history: { push } } = this.props;

    hyacinthApi.delete(`/dynamic_fields/${id}`)
      .then(() => push('/dynamic_fields'));
  }

  onChangeHandler = (event) => {
    const {
      target: {
        type, name, value, checked,
      },
    } = event;

    this.setState(produce((draft) => {
      draft.dynamicField[name] = type === 'checkbox' ? checked : value;
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
        <Form.Group as={Row}>
          <Form.Label column sm={12} xl={3}>String Key</Form.Label>
          <Col sm={12} xl={9}>
            <Form.Control
              type="text"
              name="stringKey"
              value={stringKey}
              onChange={this.onChangeHandler}
              disabled={formType === 'edit'}
            />
          </Col>
        </Form.Group>

        <Form.Group as={Row}>
          <Form.Label column sm={12} xl={3}>Display Label</Form.Label>
          <Col sm={12} xl={9}>
            <Form.Control
              type="text"
              name="displayLabel"
              value={displayLabel}
              onChange={this.onChangeHandler}
            />
          </Col>
        </Form.Group>

        <Form.Group as={Row}>
          <Form.Label column sm={12} xl={3}>Sort Order</Form.Label>
          <Col sm={12} xl={9}>
            <Form.Control
              type="number"
              name="sortOrder"
              value={sortOrder}
              onChange={this.onChangeHandler}
            />
          </Col>
        </Form.Group>

        <h4>Field Configuration</h4>

        <Form.Group as={Row}>
          <Form.Label column sm={12} xl={3}>Field Type</Form.Label>
          <Col sm={12} xl={9}>
            <Form.Control
              as="select"
              name="fieldType"
              value={fieldType}
              onChange={this.onChangeHandler}
            >
              {fieldTypes.map(t => (<option key={t} value={t}>{startCase(t)}</option>)) }
            </Form.Control>
          </Col>
        </Form.Group>

        <Form.Group as={Row}>
          <Form.Label column sm={12} xl={3}>Controlled Vocabulary</Form.Label>
          <Col sm={12} xl={9}>
            <Form.Control
              as="select"
              name="controlledVocabulary"
              value={controlledVocabulary}
              onChange={this.onChangeHandler}
              disabled={fieldType !== 'controlled_term'}
            >
              {
                vocabularies.map(v => (
                  <option key={v.stringKey} value={v.stringKey}>{v.label}</option>
                ))
              }
            </Form.Control>
          </Col>
        </Form.Group>

        <Form.Group as={Row}>
          <Form.Label column sm={12} xl={3}>Select Options</Form.Label>
          <Col sm={12} xl={9}>
            <Form.Control
              type="text"
              name="selectOptions"
              value={selectOptions}
              onChange={this.onChangeHandler}
              disabled={fieldType !== 'select'}
            />
          </Col>
        </Form.Group>

        <h4>Searching/Facets</h4>
        <Form.Group as={Row}>
          <Form.Label column sm={12} xl={3}>Filter Label</Form.Label>
          <Col sm={12} xl={9}>
            <Form.Control
              type="text"
              name="filterLabel"
              value={filterLabel}
              onChange={this.onChangeHandler}
            />
          </Col>
        </Form.Group>

        <Form.Group as={Row}>
          <Form.Label column sm={12} xl={3}>Is Facetable?</Form.Label>
          <Col sm={12} xl={9}>
            <Form.Check
              name="isFacetable"
              aria-label="is facetable option"
              checked={isFacetable}
              onChange={this.onChangeHandler}
            />
          </Col>
        </Form.Group>

        <Form.Group as={Row}>
          <Form.Label column sm={12} xl={3}>Include in:</Form.Label>
          <Col sm={12} xl={9}>
            <Form.Check
              name="isKeywordSearchable"
              label="keyword search"
              checked={isKeywordSearchable}
              onChange={this.onChangeHandler}
            />
            <Form.Check
              name="isTitleSearchable"
              label="title search"
              checked={isTitleSearchable}
              onChange={this.onChangeHandler}
            />
            <Form.Check
              name="isIdentifierSearchable"
              label="identifier search"
              checked={isIdentifierSearchable}
              onChange={this.onChangeHandler}
            />
          </Col>
        </Form.Group>

        <Form.Row>
          <Col sm="auto" className="mr-auto">
            <DeleteButton formType={formType} onClick={this.onDeleteHandler} />
          </Col>

          <Col sm="auto">
            <CancelButton to="/dynamic_fields" />
          </Col>

          <Col sm="auto">
            <SubmitButton onClick={this.onSubmitHandler} formType={formType} />
          </Col>
        </Form.Row>
      </Form>
    );
  }
}

export default withRouter(withErrorHandler(DynamicFieldForm, hyacinthApi));
