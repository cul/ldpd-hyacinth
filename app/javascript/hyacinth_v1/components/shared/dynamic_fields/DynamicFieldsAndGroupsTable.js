import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';
import {
  snakeCase, lowerFirst, words, last,
} from 'lodash';
import { withRouter, Link } from 'react-router-dom';

import hyacinthApi from '../../../utils/hyacinthApi';
import UpArrowButton from '../buttons/UpArrowButton';
import DownArrowButton from '../buttons/DownArrowButton';

class DynamicFieldsAndGroupsTable extends React.PureComponent {
  updateSortOrder(type, id, sortOrder) {
    const data = { [lowerFirst(type)]: { sortOrder } };
    const { onChange } = this.props;

    hyacinthApi.patch(`/${snakeCase(type)}s/${id}`, data)
      .then(() => onChange());
  }

  render() {
    const { rows, ...rest } = this.props;

    let body = null;

    if (!Array.isArray(rows) || !rows.length) {
      body = <p>Child elements have not been defined.</p>;
    } else {
      body = (
        <Table hover borderless {...rest}>
          <tbody>
            {
              rows.map((fieldOrGroup, index) => {
                const sortUp = (index === 0) ? null : Math.max(0, rows[index - 1].sortOrder - 1);
                const sortDown = (index === rows.length - 1) ? null : rows[index + 1].sortOrder + 1;

                const { displayLabel, id, type } = fieldOrGroup;

                return (
                  <tr key={`${type}_${id}`}>
                    <td className="text-center"><span className="badge badge-primary" style={{ fontSize: '80%' }}>{last(words(type))}</span></td>
                    <td className="text-center">
                      <Link to={`/${snakeCase(type)}s/${id}/edit`}>
                        {displayLabel}
                      </Link>
                    </td>
                    <td className="text-center">
                      <UpArrowButton
                        variant="outline-secondary"
                        onClick={() => this.updateSortOrder(type, id, sortUp)}
                        disabled={sortUp === null}
                      />
                      <DownArrowButton
                        variant="outline-secondary"
                        onClick={() => this.updateSortOrder(type, id, sortDown)}
                        disabled={sortDown === null}
                      />
                    </td>
                  </tr>
                );
              })
            }
          </tbody>
        </Table>
      );
    }
    return (body);
  }
}

DynamicFieldsAndGroupsTable.defaultProps = {
  rows: [],
};

DynamicFieldsAndGroupsTable.propTypes = {
  rows: PropTypes.arrayOf(
    PropTypes.shape({
      displayLabel: PropTypes.string.isRequired,
      id: PropTypes.number.isRequired,
      type: PropTypes.string.isRequired,
      sortOrder: PropTypes.number.isRequired,
    }),
  ),
};

export default withRouter(DynamicFieldsAndGroupsTable);
