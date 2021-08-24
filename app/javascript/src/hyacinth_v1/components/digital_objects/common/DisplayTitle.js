import React from 'react';
import PropTypes from 'prop-types';
import DisplayField from './DisplayField';

function TitleData(props) {
  const {
    data: { title },
  } = props;
  const attrs = [
    {
      stringKey: 'nonSortPortion',
      displayLabel: 'Non-Sort Portion',
      fieldType: 'string',
    },
    {
      stringKey: 'sortPortion',
      displayLabel: 'Sort Portion',
      fieldType: 'string',
    },
    {
      stringKey: 'subtitle',
      displayLabel: 'Subtitle',
      fieldType: 'string',
    },
    {
      stringKey: 'lang',
      displayLabel: 'Language',
      fieldType: 'string',
    },
  ];
  return (
    <div key="title">
      <h4 className="text-orange">Title</h4>
      {
        attrs.filter((c) => (title || {})[c.stringKey])
          .map((attr) => <DisplayField key={attr.stringKey} data={title[attr.stringKey]} dynamicField={attr} />)
      }
    </div>
  );
}

TitleData.propTypes = {
  data: PropTypes.shape({
    title: PropTypes.shape({
      nonSortPortion: PropTypes.string,
      sortPortion: PropTypes.string,
      subtitle: PropTypes.string,
      lang: PropTypes.string,
    }),
  }),
};

TitleData.defaultProps = {
  data: { title: {} },
};

export default TitleData;
