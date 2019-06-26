import React from 'react';
import produce from 'immer';
import axios from 'axios';
import { merge } from 'lodash';
import { Form, Col } from 'react-bootstrap';

import hyacinthApi, {
  enabledDynamicFields, dynamicFieldCategories,
} from '../../../util/hyacinth_api';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';
import SubmitButton from '../../layout/forms/SubmitButton';
import CancelButton from '../../layout/forms/CancelButton';
import FieldGroupArray from './FieldGroupArray';

const defaultFieldValue = {
  string: '',
  textarea: '',
  integer: '',
  boolean: false,
  select: '',
  date: '',
  controlled_term: {},
};

class MetadataForm extends React.PureComponent {
  state = {
    dynamicFields: [],
    dynamicFieldData: {},
  }

  componentDidMount = () => {
    const { data: { dynamicFieldData}, projects, digitalObjectType } = this.props;

    // this.setState(produce((draft) => {
    //   draft.digitalObject.digitalObjectDataJson.projects[0].stringKey = project;
    //   draft.digitalObject.digitalObjectDataJson.digitalObjectType = digitalObjectType;
    // }));

    // Grab all dynamic fields. Grab all the fields that are enabled for this digital object
    // type within this project. Remove any fields in the group of dynamic fields that aren't
    // enabled for this object's projects.
    axios.all([
      enabledDynamicFields.all(projects[0].stringKey, digitalObjectType),
      dynamicFieldCategories.all(),
    ]).then(axios.spread((enabledFields, dynamicFieldGraph) => {
      const enabledFieldIds = enabledFields.data.enabledDynamicFields.map(f => f.dynamicFieldId);

      const dynamicFields = dynamicFieldGraph.data.dynamicFieldCategories.map((category) => {
        category.children = this.keepEnabledFields(enabledFieldIds, category.children);
        return category;
      }).filter(c => c.children.length > 0);

      let emptyData = {};
      dynamicFields.forEach((category) => {
        this.emptyDynamicFieldData(category.children, emptyData);
      });

      this.setState(produce((draft) => {
        draft.dynamicFields = dynamicFields;
        draft.dynamicFieldData = merge(dynamicFieldData, emptyData);
      }));
    }));
  }

  onChange(fieldName, fieldVal) {
    this.setState(produce((draft) => {
      draft.dynamicFieldData[fieldName] = fieldVal;
    }));
  }

  emptyDynamicFieldData(dynamicFields, newObject) {
    dynamicFields.forEach((i) => {
      switch (i.type) {
        case 'DynamicFieldGroup':
          newObject[i.stringKey] = [this.emptyDynamicFieldData(i.children, {})];
          break;
        case 'DynamicField':
          newObject[i.stringKey] = defaultFieldValue[i.fieldType];
          break;
        default:
          break;
      }
    });

    return newObject;
  }

  keepEnabledFields(enabledFieldIds, children) {
    return children.map((c) => {
      switch (c.type) {
        case 'DynamicFieldGroup':
          c.children = this.keepEnabledFields(enabledFieldIds, c.children);
          return c.children.length > 0 ? c : null;
        case 'DynamicField':
          return enabledFieldIds.includes(c.id) ? c : null;
        default:
          return c;
      }
    }).filter(c => c !== null);
  }

  renderCategory(category) {
    const { displayLabel, children } = category;
    const { dynamicFieldData } = this.state;

    return (
      <>
        <h4 className="text-orange text-center">{displayLabel}</h4>
        {
          children.map(c => (
            <FieldGroupArray
              dynamicFieldGroup={c}
              value={dynamicFieldData[c.stringKey]}
              onChange={v => this.onChange(c.stringKey, v)}
            />
          ))
        }
      </>
    );
  }

  render() {
    const { dynamicFields } = this.state;

    return (
      <>
        { dynamicFields.map(category => this.renderCategory(category)) }

        <Form.Row>
          <Col sm="auto">
            <CancelButton to="/digital_object/:id/rights" />
          </Col>

          <Col sm="auto" className="ml-auto">
            <SubmitButton formType="edit" onClick={this.onSubmitHandler} />
          </Col>
        </Form.Row>
      </>
    );
  }
}

export default withErrorHandler(MetadataForm, hyacinthApi);
