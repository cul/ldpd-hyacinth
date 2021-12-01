import React, { useState } from 'react';
import { Card } from 'react-bootstrap';
import produce from 'immer';
import PropTypes from 'prop-types';

import Field from './Field';
import FieldGroup from './FieldGroup';

const TitleForm = (props) => {
  const {
    title: initialState, onChange,
  } = props;
  if (initialState) {
    delete initialState.__typename;
    if (initialState.value) delete initialState.value.__typename;
    if (initialState.valueLang) delete initialState.valueLang.__typename;
  }

  const [title, setTitle] = useState(initialState || {});

  const onChangeWrapper = (index, newValue) => {
    const nextValue = produce(title, (draft) => {
      draft[index] = newValue;
    });
    setTitle(nextValue);
    return onChange(nextValue);
  };

  const valueGroup = {
    stringKey: 'value',
    displayLabel: 'Value',
    children: [
      {
        id: 'nonSortPortion',
        stringKey: 'nonSortPortion',
        displayLabel: 'Non-Sort Portion',
        fieldType: 'string',
        type: 'DynamicField',
      },
      {
        id: 'sortPortion',
        stringKey: 'sortPortion',
        displayLabel: 'Sort Portion',
        fieldType: 'string',
        type: 'DynamicField',
      },
    ],
  };

  const subtitleAttr = {
    stringKey: 'subtitle',
    displayLabel: 'Subtitle',
    fieldType: 'string',
  };

  const valueLangGroup = {
    stringKey: 'valueLang',
    displayLabel: 'Language',
    children: [
      {
        id: 'tag',
        stringKey: 'tag',
        displayLabel: 'Tag',
        fieldType: 'string',
        type: 'DynamicField',
      },
    ],
  };

  return (
    <div id="title">
      <h4 className="text-orange">Title</h4>
      <FieldGroup
        key={`title_${valueGroup.stringKey}`}
        value={title.value || {}}
        index={0}
        defaultValue={{}}
        dynamicFieldGroup={valueGroup}
        onChange={(newValue) => onChangeWrapper('value', newValue)}
      />
      <FieldGroup
        key={`title_${valueLangGroup.stringKey}`}
        value={title.valueLang || {}}
        index={0}
        defaultValue={{}}
        dynamicFieldGroup={valueLangGroup}
        onChange={(newValue) => onChangeWrapper('valueLang', newValue)}
      />
      <Field
        key={subtitleAttr.stringKey}
        inputName={`title-${subtitleAttr.stringKey}`}
        value={title[subtitleAttr.stringKey] || ''}
        dynamicField={subtitleAttr}
        onChange={(v) => onChangeWrapper(subtitleAttr.stringKey, v)}
      />
    </div>
  );
};

TitleForm.propTypes = {
  onChange: PropTypes.func.isRequired,
  title: PropTypes.shape(
    {
      value: PropTypes.shape({
        nonSortPortion: PropTypes.string,
        sortPortion: PropTypes.string,
      }),
      subtitle: PropTypes.string,
      valueLang: PropTypes.shape({
        tag: PropTypes.string,
      }),
    },
  ),
};

TitleForm.defaultProps = {
  title: {
    value: {
      nonSortPortion: '',
      sortPortion: '',
    },
    valueLang: {
      tag: '',
    },
    subtitle: '',
  },
};

export default TitleForm;
