import React from 'react';
import PropTypes from 'prop-types';
import { Card } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';
import { has } from 'lodash';

const titleForDigitalObject = (digObj) => {
  let title = '[No Title]';
  if (has(digObj, 'dynamicFieldData.title[0]')) {
    const titleData = digObj.dynamicFieldData.title[0];
    title = titleData.titleSortPortion;
    if (titleData.titleNonSortPortion) {
      title = `${titleData.titleNonSortPortion} ${title}`;
    }
  }
  return title;
};


const DigitalObjectList = (props) => {
  const { digitalObjects } = props;

  return (
    <>
      {
        digitalObjects.map(digitalObject => (
          <Card key={digitalObject.id} className="mb-3">
            <Card.Header>{titleForDigitalObject(digitalObject)}</Card.Header>
            <Card.Body>
              <LinkContainer to={`/digital_objects/${digitalObject.id}`}>
                <Card.Link>{digitalObject.id}</Card.Link>
              </LinkContainer>
              <Card.Text>{digitalObject.digitalObjectType}</Card.Text>
            </Card.Body>
          </Card>
        ))
      }
    </>
  );
};

DigitalObjectList.propTypes = {
  digitalObjects: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.string.isRequired,
      digitalObjectType: PropTypes.string.isRequired,
      dynamicFieldData: PropTypes.object.isRequired,
    }),
  ).isRequired,
};

export default DigitalObjectList;
