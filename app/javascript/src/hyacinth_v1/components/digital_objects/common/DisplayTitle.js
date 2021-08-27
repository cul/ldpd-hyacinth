import React from 'react';
import PropTypes from 'prop-types';
import DisplayField from './DisplayField';
import DisplayFieldGroup from './DisplayFieldGroup';

function TitleData(props) {
  const {
    data: {
      title,
    },
  } = props;
  const {
    value: titleValue,
    valueLang,
    subtitle,
  } = (title || {});

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
    <div key="title">
      <h4 className="text-orange">Title</h4>
      <DisplayFieldGroup key={valueGroup.stringKey} data={titleValue ? [titleValue] : []} dynamicFieldGroup={valueGroup} />
      <DisplayFieldGroup key={valueLangGroup.stringKey} data={valueLang ? [valueLang] : []} dynamicFieldGroup={valueLangGroup} />
      <DisplayField key={subtitleAttr.stringKey} data={subtitle ? [subtitle] : []} dynamicField={subtitleAttr} />
    </div>
  );
}

TitleData.propTypes = {
  data: PropTypes.shape({
    title: PropTypes.shape({
      value: PropTypes.shape({
        nonSortPortion: PropTypes.string,
        sortPortion: PropTypes.string,
      }),
      subtitle: PropTypes.string,
      valueLang: PropTypes.shape({
        tag: PropTypes.string,
      }),
    }),
  }),
};

TitleData.defaultProps = {
  data: {
    title: {
      value: {},
      valueLang: {},
    },
  },
};

export default TitleData;
