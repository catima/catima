var FontMenu = React.createClass({

  handleChange: function(e){
    this.props.onChange({fontFamily: e.target.value})
  },

  render: function(){
    return (
      <select className="form-control btn btn-sm btn-default"
        value={this.props.value}
        onChange={this.handleChange}
        style={{height: '30px', width: '150px'}}>
          <option value="">Default</option>
          <option disabled>---</option>
          <option value='Arial, Helvetica, sans-serif'>Arial</option>
          <option value='"Arial Black", Gadget, sans-serif'>Arial Black</option>
          <option value='"Comic Sans MS", cursive, sans-serif'>Comic Sans</option>
          <option value='"Courier New", Courier, monospace'>Courier</option>
          <option value='Geneva, Tahoma, sans-serif'>Geneva</option>
          <option value='Georgia, serif'>Georgia</option>
          <option value='"Helvetica Neue", Helvetica, Verdana, sans-serif'>Helvetica Neue</option>
          <option value='Impact, Charcoal, sans-serif'>Impact</option>
          <option value='"Lucida Sans Unicode", "Lucida Grande", sans-serif'>Lucida Sans</option>
          <option value='Monaco, "Lucida Console", monospace'>Monaco</option>
          <option value='"Palatino Linotype", "Book Antiqua", Palatino, serif'>Palatino</option>
          <option value='"Times New Roman", Times, serif'>Times</option>
          <option value='"Trebuchet MS", Helvetica, sans-serif'>Trebuchet</option>
          <option value='Verdana, Geneva, sans-serif'>Verdana</option>
      </select>
    )
  }
});
