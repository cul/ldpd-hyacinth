import React from 'react';

import ContextualNavbar from '../../layout/ContextualNavbar';

export default class ItemShow extends React.Component {

  render(){
    return(
      <ContextualNavbar
        title="Editing Item"
        rightHandLinks={[
          { link: '/digital-objects/1/rights', label: 'Rights' },
          { link: '/digital-objects/1/edit', label: 'Edit' },
        ]}
      />
    )
  }
}
