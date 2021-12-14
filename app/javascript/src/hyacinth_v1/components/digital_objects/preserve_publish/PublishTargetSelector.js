import React from 'react';
import PropTypes from 'prop-types';
import {
  Button, ButtonGroup, OverlayTrigger, ToggleButton, Tooltip,
} from 'react-bootstrap';
import produce from 'immer';
import ReadableDate from '../../shared/ReadableDate';
import FontAwesomeIcon from '../../../utils/lazyFontAwesome';

const SKIP = 'skip';
const PUBLISH = 'publish';
const UNPUBLISH = 'unpublish';

const buttonStyleOptions = [
  {
    operation: UNPUBLISH,
    label: 'Unpublish',
    buttonVariant: 'danger',
  },
  {
    operation: SKIP,
    label: 'Skip',
    buttonVariant: 'secondary',
  },
  {
    operation: PUBLISH,
    label: 'Publish',
    buttonVariant: 'success',
  },
];

const PublishTargetSelector = ({
  availablePublishTargets, currentPublishEntries, publishOperationSelections, readOnly, onChange, className,
}) => {
  const onPublishOperationSelection = (stringKey, operation) => {
    onChange(produce(publishOperationSelections, (draft) => {
      [PUBLISH, UNPUBLISH].forEach((possibleOp) => {
        const index = draft[possibleOp]?.indexOf(stringKey);
        if (index !== undefined && index > -1) { draft[possibleOp].splice(index, 1); }
      });
      if (operation !== SKIP) {
        draft[operation] ||= [];
        draft[operation].push(stringKey);
      }
    }));
  };

  const selectAllPublishTargets = (operation) => {
    onChange(produce(publishOperationSelections, (draft) => {
      [PUBLISH, UNPUBLISH].forEach((possibleOp) => { draft[possibleOp] = []; });
      if (operation !== SKIP) {
        draft[operation] = [...availablePublishTargets];
      }
    }));
  };

  const currentPublishOperationFor = (stringKey) => {
    if (publishOperationSelections[PUBLISH]?.includes(stringKey)) {
      return PUBLISH;
    }
    if (publishOperationSelections[UNPUBLISH]?.includes(stringKey)) {
      return UNPUBLISH;
    }
    return SKIP;
  };

  const publishEntryFor = (stringKey) => currentPublishEntries.find((pubEntry) => pubEntry.publishTarget.stringKey === stringKey);

  return (
    <div className={className}>
      {
        availablePublishTargets.map((publishTargetStringKey) => {
          const correspondingPublishEntry = publishEntryFor(publishTargetStringKey);
          const currentPublishOperationSelection = currentPublishOperationFor(publishTargetStringKey);
          const label = publishTargetStringKey;

          return (
            <div className="row align-items-center py-1 border-bottom" key={publishTargetStringKey}>
              <div className="col-md">
                {label}
              </div>
              <div className="col-md-auto pe-5">
                {
                  correspondingPublishEntry
                    ? (
                      <OverlayTrigger
                        placement="top"
                        overlay={(
                          <Tooltip>
                            Last Published:
                            <br />
                            <ReadableDate isoDate={correspondingPublishEntry.publishedAt} />
                            {' by '}
                            {correspondingPublishEntry.publishedBy.fullName}
                          </Tooltip>
                        )}
                      >
                        <span className="text-muted">
                          Published
                          {' '}
                          <FontAwesomeIcon icon="info-circle" />
                        </span>
                      </OverlayTrigger>
                    )
                    : <span className="text-muted">Not published</span>
                }
              </div>
              {readOnly
                || (
                  <div className="col-md-auto">
                    <ButtonGroup>
                      {
                        buttonStyleOptions.map((option) => (
                          <ToggleButton
                            key={option.operation}
                            id={`${publishTargetStringKey}-${option.operation}`}
                            type="radio"
                            variant={`outline-${option.buttonVariant}`}
                            name={`${publishTargetStringKey}-publish-action`}
                            value={option.operation}
                            checked={currentPublishOperationSelection === option.operation}
                            onChange={(e) => onPublishOperationSelection(publishTargetStringKey, e.currentTarget.value)}
                          >
                            {option.label}
                          </ToggleButton>
                        ))
                      }
                    </ButtonGroup>
                  </div>
                )}
            </div>
          );
        })
      }
      {
        availablePublishTargets.length > 1
        && (
          <div className="text-end py-1 border-bottom">
            <Button variant="outline-danger me-1" onClick={() => { selectAllPublishTargets(UNPUBLISH); }}>Unpublish All</Button>
            <Button variant="outline-info me-1" onClick={() => { selectAllPublishTargets(SKIP); }}>Skip All</Button>
            <Button variant="outline-success" onClick={() => { selectAllPublishTargets(PUBLISH); }}>Publish All</Button>
          </div>
        )
      }
    </div>
  );
};

export default PublishTargetSelector;

PublishTargetSelector.defaultProps = {
  readOnly: false,
  className: undefined,
};

PublishTargetSelector.propTypes = {
  availablePublishTargets: PropTypes.arrayOf(PropTypes.string).isRequired,
  currentPublishEntries: PropTypes.arrayOf(
    PropTypes.shape({
      publishTarget: PropTypes.shape({
        stringKey: PropTypes.string.isRequired,
      }).isRequired,
      publishedAt: PropTypes.string.isRequired,
      publishedBy: PropTypes.shape({
        fullName: PropTypes.string.isRequired,
      }),
    }),
  ).isRequired,
  className: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  readOnly: PropTypes.bool,
  publishOperationSelections: PropTypes.shape({
    [PUBLISH]: PropTypes.arrayOf(PropTypes.string),
    [UNPUBLISH]: PropTypes.arrayOf(PropTypes.string),
  }).isRequired,
};
