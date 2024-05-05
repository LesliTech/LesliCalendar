<p align="center">
	<img width="90" alt="LesliCloud logo" src="../app/assets/images/lesli_calendar/calendar-logo.svg" />
    <h3 align="center">Unified calendar app for The Lesli Framework.</h3>
</p>

<hr/>
    <p align="center">
        <a target="blank" href="https://rubygems.org/gems/lesli_calendar">
            <img src="https://badge.fury.io/rb/lesli_calendar.svg" alt="Gem Version" height="18">
        </a>
    </p>
<hr/>

### Quick start

```shell
# Add lesli_calendar engine
bundle add lesli_calendar
```

```shell
# Setup database
rake lesli:db:setup
```

```ruby
# Load lesli_calendar
Rails.application.routes.draw do
    mount lesli_calendar::Engine => "/calendar"
end
```
