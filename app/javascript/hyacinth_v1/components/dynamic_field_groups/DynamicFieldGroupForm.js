import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Row, Col, Form, Tabs, Tab,
} from 'react-bootstrap';
import { useHistory } from 'react-router-dom';
import { useQuery, useMutation } from '@apollo/react-hooks';
import { produce } from 'immer';

import FormButtons from '../shared/forms/FormButtons';
import InputGroup from '../shared/forms/InputGroup';
import Label from '../shared/forms/Label';
import NumberInput from '../shared/forms/inputs/NumberInput';
import TextInput from '../shared/forms/inputs/TextInput';
import Checkbox from '../shared/forms/inputs/Checkbox';
import JSONInput from '../shared/forms/inputs/JSONInput';
import DynamicFieldCategorySelect from '../shared/forms/inputs/selects/DynamicFieldCategorySelect';
import {
  createDynamicFieldGroupMutation,
  updateDynamicFieldGroupMutation,
  deleteDynamicFieldGroupMutation,
} from '../../graphql/dynamicFieldGroups';
import GraphQLErrors from '../shared/GraphQLErrors';
import DynamicFieldGroupChildren from './DynamicFieldGroupChildren';
import { fieldExportProfilesQuery } from '../../graphql/fieldExportProfiles';

function DynamicFieldGroupForm(props) {
  const { formType, dynamicFieldGroup, defaultValues } = props;
  const id = dynamicFieldGroup ? dynamicFieldGroup.id : null;

  const history = useHistory();

  const transformExportRules = rules => rules.map(r => ({
    id: r.id,
    fieldExportProfileId: r.fieldExportProfile.id,
    translationLogic: r.translationLogic,
  }));

  const [stringKey, setStringKey] = useState(dynamicFieldGroup ? dynamicFieldGroup.stringKey : '');
  const [displayLabel, setDisplayLabel] = useState(dynamicFieldGroup ? dynamicFieldGroup.displayLabel : '');
  const [sortOrder, setSortOrder] = useState(
    dynamicFieldGroup ? dynamicFieldGroup.sortOrder : null,
  );
  const [isRepeatable, setIsRepeatable] = useState(
    dynamicFieldGroup ? dynamicFieldGroup.isRepeatable : false,
  );
  const [parentType] = useState(
    dynamicFieldGroup ? dynamicFieldGroup.parent.type : defaultValues.parentType,
  );
  const [parentId, setParentId] = useState(
    dynamicFieldGroup ? dynamicFieldGroup.parent.id : defaultValues.parentId,
  );
  const [exportRules, setExportRules] = useState(
    dynamicFieldGroup ? transformExportRules(dynamicFieldGroup.exportRules) : [],
  );

  const [createDynamicFieldGroup, { error: createError }] = useMutation(
    createDynamicFieldGroupMutation,
  );
  const [updateDynamicFieldGroup, { error: updateError }] = useMutation(
    updateDynamicFieldGroupMutation,
  );
  const [deleteDynamicFieldGroup, { error: deleteError }] = useMutation(
    deleteDynamicFieldGroupMutation,
  );

  const { data: fieldExportProfileResponse } = useQuery(fieldExportProfilesQuery, {
    onCompleted: (data) => {
      setExportRules(prevExportRules => produce(prevExportRules, (draft) => {
        data.fieldExportProfiles.forEach((p) => {
          if (!prevExportRules.map(i => i.fieldExportProfileId).includes(p.id)) {
            draft.push({ fieldExportProfileId: p.id, translationLogic: '{}' });
          }
        });
      }));
    },
  });

  const onTranslationRuleChange = (fieldExportProfileId, translationLogic) => {
    setExportRules(prevExportRules => produce(prevExportRules, (draft) => {
      const index = draft.findIndex(e => e.fieldExportProfileId === fieldExportProfileId);
      draft[index].translationLogic = translationLogic;
    }));
  };

  const onDeleteHandler = (event) => {
    event.preventDefault();

    const variables = { input: { id } };

    deleteDynamicFieldGroup({ variables }).then(() => history.push('/dynamic_fields'));
  };

  const onSave = () => {
    const variables = {
      input: {
        displayLabel, sortOrder, isRepeatable, parentType, parentId, exportRules,
      },
    };

    switch (formType) {
      case 'new':
        variables.input.stringKey = stringKey;
        return createDynamicFieldGroup({ variables }).then((res) => {
          const { dynamicFieldGroup: { id: newId } } = res.data.createDynamicFieldGroup;

          history.push(`/dynamic_field_groups/${newId}/edit`);
        });
      case 'edit':
        variables.input.id = id;
        return updateDynamicFieldGroup({ variables });
      default:
        return null;
    }
  };

  return (
    <Row>
      <Col sm={7}>
        <Form>
          <GraphQLErrors errors={createError || updateError || deleteError} />
          <InputGroup>
            <Label sm={12} xl={3}>String Key</Label>
            <TextInput sm={12} xl={9} value={stringKey} onChange={setStringKey} disabled={formType === 'edit'} />
          </InputGroup>

          <InputGroup>
            <Label sm={12} xl={3}>Display Label</Label>
            <TextInput sm={12} xl={9} value={displayLabel} onChange={setDisplayLabel} />
          </InputGroup>

          <InputGroup>
            <Label sm={12} xl={3}>Sort Order</Label>
            <NumberInput sm={12} xl={9} value={sortOrder} onChange={setSortOrder} />
          </InputGroup>

          {
            parentType === 'DynamicFieldCategory' && (
              <InputGroup>
                <Label sm={12} xl={3}>Dynamic Field Category</Label>
                <DynamicFieldCategorySelect
                  sm={12}
                  xl={9}
                  value={parentId}
                  onChange={setParentId}
                />
              </InputGroup>
            )
          }

          <InputGroup>
            <Label sm={12} xl={3}>Is Repeatable?</Label>
            <Checkbox sm={12} xl={9} value={isRepeatable} onChange={setIsRepeatable} />
          </InputGroup>

          <InputGroup>
            <Label sm={12} xl={3}>Export Rules</Label>
            <Col sm={12} xl={9}>
              {
                fieldExportProfileResponse && exportRules.length > 0 ? (
                  <Tabs id="export_profiles">
                    {
                      exportRules.map((rule) => {
                        const { fieldExportProfileId, translationLogic } = rule;
                        const { fieldExportProfiles } = fieldExportProfileResponse;
                        const { name } = fieldExportProfiles.find(p => (
                          p.id === fieldExportProfileId
                        ));

                        return (
                          <Tab eventKey={name} title={name} key={name}>
                            <JSONInput
                              sm={12}
                              name={`${name}_input`}
                              value={translationLogic}
                              onChange={v => onTranslationRuleChange(fieldExportProfileId, v)}
                            />
                          </Tab>
                        );
                      })
                    }
                  </Tabs>
                ) : '-- None ---'
              }
            </Col>
          </InputGroup>

          <FormButtons
            formType={formType}
            cancelTo="/dynamic_fields"
            onDelete={onDeleteHandler}
            onSave={onSave}
          />
        </Form>
      </Col>
      <Col sm={5}>
        <DynamicFieldGroupChildren id={id} />
      </Col>
    </Row>
  );
}

DynamicFieldGroupForm.defaultProps = {
  dynamicFieldGroup: null,
  defaultValues: null,
};

DynamicFieldGroupForm.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  dynamicFieldGroup: PropTypes.shape({
    id: PropTypes.string.isRequired,
  }),
  defaultValues: PropTypes.shape({
    parentId: PropTypes.string.isRequired,
    parentType: PropTypes.string.isRequired,
  }),
};

export default DynamicFieldGroupForm;
