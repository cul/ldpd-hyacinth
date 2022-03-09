import React from 'react';
import PropTypes from 'prop-types';
import { Alert } from 'react-bootstrap';

function DigitalObjectSummary(props) {
  const {
    digitalObject: {
      id, state, doi, primaryProject, otherProjects, numberOfChildren,
    },
  } = props;

  return (
    <div className="my-3">
      {
        state === 'DELETED' && (
          <Alert variant="danger">
            This object has been deleted.
          </Alert>
        )
      }
      <dl className="row mb-0">
        <dt className="col-sm-3">Primary Project</dt>
        <dd className="col-sm-9">
          <strong>{primaryProject.displayLabel}</strong>
        </dd>
        <dt className="col-sm-3">Other Projects</dt>
        <dd className="col-sm-9">
          {otherProjects.length === 0
            ? '- None -'
            : otherProjects.map((p, i) => (
              <span key={p.stringKey}>
                {p.displayLabel}
                {i + 1 < otherProjects.length ? ', ' : ''}
              </span>
            ))}
        </dd>

        <dt className="col-sm-3">UID</dt>
        <dd className="col-sm-9">{id || '- Assigned After Save -'}</dd>

        <dt className="col-sm-3">DOI</dt>
        <dd className="col-sm-9">{doi || '- Assigned After Publish -'}</dd>
      </dl>
      {
        id && (
          <>
            <dl className="row mb-0">
              <dt className="col-sm-3">Child Objects</dt>
              <dd className="col-sm-9">{numberOfChildren}</dd>

              <dt className="col-sm-3">View As</dt>
              <dd className="col-sm-9">
                <a href={`/api/v1/digital_objects/${id}.json`} target="_blank" rel="noopener noreferrer">JSON</a>
              </dd>
            </dl>
          </>
        )
      }
    </div>
  );
}

export default DigitalObjectSummary;

DigitalObjectSummary.propTypes = {
  digitalObject: PropTypes.objectOf(PropTypes.any).isRequired,
};
