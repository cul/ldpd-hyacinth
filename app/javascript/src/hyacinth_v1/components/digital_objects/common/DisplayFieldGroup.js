import React from 'react';
import { Card } from 'react-bootstrap';

import DisplayField from './DisplayField';

function DisplayFieldGroup(props) {
  const {
    data, // is an array
    dynamicFieldGroup: {
      stringKey,
      displayLabel,
      isRepeatable,
      children, // is an array
    },
  } = props;

  return (
    data.map((d, i) => (
      <Card key={`${stringKey}_${i + 1}`}>
        <Card.Header>
          {displayLabel}
          {isRepeatable ? ` ${i + 1}` : ''}
        </Card.Header>
        <Card.Body>
          {
            children.map((c) => {
              if (d[c.stringKey]) {
                if (c.type === 'DynamicFieldGroup') {
                  return <DisplayFieldGroup key={c.id} data={d[c.stringKey]} dynamicFieldGroup={c} />;
                } if (c.type === 'DynamicField') {
                  return <DisplayField key={c.id} data={d[c.stringKey]} dynamicField={c} />;
                }
              }
              return '';
            })
          }
        </Card.Body>
      </Card>
    ))
  );
}

export default DisplayFieldGroup;
