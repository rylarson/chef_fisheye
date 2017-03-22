# fisheye-cookbook

This cookbook installs Atlassian Fisheye. It does not install Java
for you. Do that as part of your own wrapper/role.

You just need to configure the location (URI) of the FishEye zip
file that you want to install and the cookbook does the rest of the
work for you

## Supported Platforms

Centos 7.x

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['fisheye']['zip_file_uri']</tt></td>
    <td>String</td>
    <td>URI to the fisheye ZIP file you wish to install</td>
    <td><tt>nil</tt></td>
  </tr>
</table>

## Usage

### fisheye::default

Include `fisheye` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[fisheye::default]"
  ]
}
```

## License and Authors

Author:: Ryan Larson (<ryan.mango.larson@gmail.com>)
