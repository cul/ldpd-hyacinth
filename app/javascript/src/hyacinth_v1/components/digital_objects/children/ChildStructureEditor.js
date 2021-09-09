import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';
import { Badge, Card } from 'react-bootstrap';
import { startCase } from 'lodash';
import { DragDropContext, Droppable, Draggable } from 'react-beautiful-dnd';

const ChildStructureEditor = (props) => {
  const {
    digitalObjects, onRearrange,
  } = props;

  const [currentObjectList, setCurrentObjectList] = useState(digitalObjects);

  const onDragEnd = (result) => {
    const { destination, source } = result;

    if (!destination) {
      return;
    }

    // no changes
    if (
      destination.droppableId === source.droppableId
      && destination.index === source.index
    ) {
      return;
    }

    const newList = Array.from(currentObjectList);
    // insert dragged element to new location
    newList.splice(destination.index, 0, newList.splice(source.index, 1)[0]);
    setCurrentObjectList(newList);
    onRearrange(newList);
  };

  return (
    <DragDropContext onDragEnd={onDragEnd}>
      <Droppable droppableId="droppable-1">
        {(DroppableProvided) => (
          <div
            ref={DroppableProvided.innerRef}
            {...DroppableProvided.droppableProps}
          >
            {
              currentObjectList.map((digitalObject, resultIndex) => (
                <Draggable
                  draggableId={
                    digitalObject.id
                  }
                  index={resultIndex}
                  key={digitalObject.id}
                >
                  {(provided) => (
                    <Card
                      key={digitalObject.id}
                      className="mb-3"
                      {...provided.draggableProps}
                      {...provided.dragHandleProps}
                      ref={provided.innerRef}
                    >
                      <Card.Header>
                        <Link
                          to={`/digital_objects/${digitalObject.id}`}
                        >
                          {digitalObject.displayLabel}
                        </Link>
                      </Card.Header>
                      <Card.Body>
                        <ul className="list-unstyled small">
                          <li>
                            <strong>ID: </strong>
                            {digitalObject.id}
                          </li>
                          {
                            digitalObject.numberOfChildren > 0 && (
                              <li>
                                <strong>Children: </strong>
                                {digitalObject.numberOfChildren}
                              </li>
                            )
                          }
                        </ul>
                        <Badge bg="secondary">{startCase(digitalObject.digitalObjectType)}</Badge>
                      </Card.Body>
                    </Card>
                  )}
                </Draggable>

              ))
            }

            {DroppableProvided.placeholder}
          </div>

        )}
      </Droppable>
    </DragDropContext>
  );
};

ChildStructureEditor.defaultProps = {
};

ChildStructureEditor.propTypes = {
  digitalObjects: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.string.isRequired,
      digitalObjectType: PropTypes.string.isRequired,
    }),
  ).isRequired,
  onRearrange: PropTypes.func.isRequired,
};

export default ChildStructureEditor;
