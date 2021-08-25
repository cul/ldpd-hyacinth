import React, { useState } from 'react';
import { Card } from 'react-bootstrap';
import produce from 'immer';
import PropTypes from 'prop-types';

import Field from './Field';

const TitleForm = (props) => {
  const {
    title: initialState, onChange,
  } = props;
  const { __typename, ...cleanedInitialState } = (initialState || {});

  const [title, setTitle] = useState(cleanedInitialState);

  const onChangeWrapper = (index, newValue) => {
    const nextValue = produce(title, (draft) => {
      draft[index] = newValue;
    });
    setTitle(nextValue);
    return onChange(nextValue);
  };

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
    <Card className="my-2" key="title">
      <Card.Header>Title</Card.Header>
      <Card.Body>
        {
          attrs.map(
            (c) => (
              <Field
                key={c.stringKey}
                inputName={`title-${c.stringKey}`}
                value={title[c.stringKey]}
                dynamicField={c}
                onChange={(v) => onChangeWrapper(c.stringKey, v)}
              />
            ),
          )
        }
      </Card.Body>
    </Card>
  );
};

TitleForm.propTypes = {
  onChange: PropTypes.func.isRequired,
  title: PropTypes.shape(
    {
      nonSortPortion: PropTypes.string,
      sortPortion: PropTypes.string,
      subtitle: PropTypes.string,
      lang: PropTypes.string,
    },
  ),
};

TitleForm.defaultProps = {
  title: {},
};

export default TitleForm;
