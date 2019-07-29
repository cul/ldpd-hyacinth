import React from 'react';
import produce from 'immer';
import axios from 'axios';
import { merge, camelCase } from 'lodash';
import { Form, Col, Fade } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';

import hyacinthApi, {
  enabledDynamicFields, dynamicFieldCategories, digitalObject,
} from '../../../util/hyacinth_api';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';
import TabHeading from '../../ui/tabs/TabHeading';
import FieldGroupArray from './FieldGroupArray';
import digitalObjectInterface from '../digitalObjectInterface';
import FormButtons from '../../ui/forms/FormButtons';
import InputGroup from '../../ui/forms/InputGroup';
import TextInputWithAddAndRemove from '../../ui/forms/inputs/TextInputWithAddAndRemove';

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
    formType: 'edit',
    uid: '',
    dynamicFields: [],
    dynamicFieldData: {},
    defaultFieldData: {},
    identifiers: [],
    loading: true,
  }

  componentDidMount = () => {
    const {
      data: {
        uid, dynamicFieldData, projects, digitalObjectType, identifiers
      },
      formType,
    } = this.props;
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
        draft.uid = uid;
        draft.formType = formType;
        draft.dynamicFields = dynamicFields;
        draft.defaultFieldData = emptyData;
        draft.dynamicFieldData = merge({}, emptyData, dynamicFieldData);
        draft.identifiers = identifiers;
        draft.loading = false
      }));
    }));
  }

  onChange(fieldName, fieldVal) {
    this.setState(produce((draft) => {
      draft.dynamicFieldData[fieldName] = fieldVal;
    }));
  }

  onIdentifierChange(value) {
    this.setState(produce((draft) => {
      draft.identifiers = value;
    }));
  }

  onSubmitHandler = () => {
    const { dynamicFieldData, identifiers, uid, formType } = this.state;
    const { history: { push } } = this.props;

    if (formType === 'edit') {
      return digitalObject.update(
        uid,
        { digitalObject: { dynamicFieldData, identifiers } },
      ).then(res => push(`/digital_objects/${res.data.digitalObject.uid}`));
    }

    if (formType === 'new') {
      const { data } = this.props;

      return digitalObject.create({
        digitalObject: { dynamicFieldData, identifiers, ...data },
      }).then(res => push(`/digital_objects/${res.data.digitalObject.uid}`));
    }
  }

  emptyDynamicFieldData(dynamicFields, newObject) {
    dynamicFields.forEach((i) => {
      switch (i.type) {
        case 'DynamicFieldGroup':
          newObject[camelCase(i.stringKey)] = [this.emptyDynamicFieldData(i.children, {})];
          break;
        case 'DynamicField':
          newObject[camelCase(i.stringKey)] = defaultFieldValue[i.fieldType];
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
    const { dynamicFieldData, defaultFieldData } = this.state;

    return (
      <div key={displayLabel}>
        <h4 className="text-orange">{displayLabel}</h4>
        {
          children.map(c => (
            <FieldGroupArray
              key={`array_${c.stringKey}`}
              dynamicFieldGroup={c}
              value={dynamicFieldData[camelCase(c.stringKey)]}
              defaultValue={defaultFieldData[camelCase(c.stringKey)][0]}
              onChange={v => this.onChange(camelCase(c.stringKey), v)}
            />
          ))
        }
      </div>
    );
  }

  render() {
    const {
      loading, dynamicFields, identifiers, formType, uid,
    } = this.state;

    return (
      <>
        <TabHeading>
          Metadata
          {/* <EditButton
            className="float-right"
            size="lg"
            link={`/digital_objects/${id}/metadata/edit`}
          /> */}
        </TabHeading>

        <Fade in={!loading}>
          <div>
            { dynamicFields.map(category => this.renderCategory(category)) }

            <h4 className="text-orange">Identifiers</h4>
            <InputGroup>
              <TextInputWithAddAndRemove
                sm={12}
                values={identifiers}
                onChange={v => this.onIdentifierChange(v)}
              />
            </InputGroup>

            <FormButtons
              formType={formType}
              cancelTo={`/digital_objects/${uid}/metadata`}
              onSave={this.onSubmitHandler}
            />
          </div>
        </Fade>
      </>
    );
  }
}

export default digitalObjectInterface(MetadataForm);
