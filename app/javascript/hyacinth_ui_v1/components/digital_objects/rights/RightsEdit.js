import React from 'react';

import ItemRightsEdit from './ItemRightsEdit';

export default class RightsEdit extends React.Component {

  componentDidMount(){
    // Query for digital object information
  }

  render(){
    // If digital object is item
    //   render item rights page
    // else
    //   render asset rights page
    // end

    // Pass in dynamic field data (might need all of the digital object data) to ItemRightsEdit or AssetRightsEdit.
    const { data } = this.props;

    return (
      <ItemRightsEdit data={data}/>
    )
  }
}
