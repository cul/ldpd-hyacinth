import React from 'react';
import PropTypes from 'prop-types';
import { Card } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';

const DigitalObjectList = (props) => {
  const { digitalObjects } = props;

  return (
    <>
      {
        digitalObjects.map(digitalObject => (
          <Card key={digitalObject.id} className="mb-3">
            <Card.Header>{digitalObject.title}</Card.Header>
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
      title: PropTypes.string.isRequired,
    }),
  ).isRequired,
};

export default DigitalObjectList;
