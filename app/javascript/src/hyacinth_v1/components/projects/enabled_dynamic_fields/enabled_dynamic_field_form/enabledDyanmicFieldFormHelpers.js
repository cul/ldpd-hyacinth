import produce from 'immer';

export const findDynamicFields = (searchTarget, dynamicFields = []) => {
  if (searchTarget instanceof Array) {
    searchTarget.forEach((el) => findDynamicFields(el, dynamicFields));
  } else if (searchTarget instanceof Object) {
    if (searchTarget.type === 'DynamicField') {
      dynamicFields.push(searchTarget);
    } else {
      Object.values(searchTarget).forEach((val) => {
        findDynamicFields(val, dynamicFields);
      });
    }
  }
  return dynamicFields;
};

export const edfReducer = (state, action) => {
  switch (action.type) {
    case 'init':
      return produce(state, (draft) => {
        const { dynamicFieldGraph, enabledDynamicFields, fieldSetOptions } = action.payload;

        // We're going to build a modified graph from the retrieved graph, so we'll use the
        // produce() method to create a deep copy.  Fields in the original dynamicFieldGraph
        // variable are immutable because they're frozen by the Apollo client upon retrieval.
        draft.enabledFieldHierarchy = produce(dynamicFieldGraph, (enabledFieldHierarchyDraft) => {
          // We'll merge enabledFieldData and fieldSetOptions into dynamicFieldGraph to fill in
          // the enabledFieldHierarchy.
          const dynamicFieldIdsToEnabledDynamicFields = enabledDynamicFields.reduce((accumulator, current) => {
            accumulator[current.dynamicField.id] = current;
            return accumulator;
          }, {});
          const dynamicFields = findDynamicFields(enabledFieldHierarchyDraft);
          dynamicFields.forEach((dynamicField) => {
            dynamicField.enabledFieldData = dynamicFieldIdsToEnabledDynamicFields[dynamicField.id];
            dynamicField.fieldSetOptions = fieldSetOptions;
          });
        });
      });
    case 'update':
      return produce(state, (draft) => {
        const { newEnabledFieldData } = action.payload;
        const dynamicFields = findDynamicFields(draft.enabledFieldHierarchy);
        const targetField = dynamicFields.find((dynamicField) => {
          const dynamicFieldId = parseInt(dynamicField.id, 10);
          const targetDynamicFieldId = parseInt(newEnabledFieldData.dynamicField.id, 10);
          return dynamicFieldId === targetDynamicFieldId;
        });
        targetField.enabledFieldData = newEnabledFieldData;
      });
    default:
      throw new Error(`Unexpected action type: ${action.type}`);
  }
};
