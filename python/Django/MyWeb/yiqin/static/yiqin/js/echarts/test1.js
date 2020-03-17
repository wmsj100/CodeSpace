layui.use(['jquery'], function(){
	let $ = layui.jquery;
	let myChart = echarts.init($('#main')[0])
	let option = {
            title: {
                text: 'ECharts 入门示例'
            },
            tooltip: {},
            legend: {
                data:['销量']
            },
            xAxis: {
                data: ["衬衫","羊毛衫","雪纺衫","裤子","高跟鞋","袜子"]
            },
            yAxis: {},
			backgroundColor: '#2c343c',
			textStyle: {
				color: 'rgba(255, 255, 255, 0.3)',	
			},
            series: [{
                name: '销量',
                type: 'bar',
                data: [5, 20, 36, 10, 10, 20]
            }]
        };
	myChart.setOption(option);

	let test1Chart = echarts.init($('#test1')[0], 'light');
	test1Opt = {
		series: [
			{
				name: '访问来源',
				type: 'pie',
            	radius: '55%',
				roseType: 'angle',
				itemStyle: {
					shadowBlur: 200,
					shadowOffsetX: 0,
					shadowOffsetY: 0,
					shadowColor: 'rgba(0, 0, 0, 0.5)'
				},
            	data:[
            	    {value:235, name:'视频广告'},
            	    {value:274, name:'联盟广告'},
            	    {value:310, name:'邮件营销'},
            	    {value:335, name:'直接访问'},
            	    {value:400, name:'搜索引擎'}
				]
			}
		]
	}
	test1Chart.setOption(test1Opt);

	let yiqinChart = echarts.init($('#yiqin')[0]);
	yiqinOpt = {
		title: { text: '中国疫情数据统计' },
		tooltip: {
			trigger: 'axis'
		},
		legend: {
			data: ['确诊', '疑似', '死亡', '出院', '死亡率', '治愈率']
		},
		grid: {
			left: '3%',
			right: '4%',
			bottom: '3%',
			containLabel: true
		},
		toolbox: {
			feature: {
				saveAsImage: {}
			}
		},
		xAxis: {
			type: 'category',
			boundaryGap: false,
			data: []
		},
		yAxis: {
			type: 'value'
		},
		series: []
	}
	yiqinChart.setOption(yiqinOpt);
	$.get('/yiqin/api/chinadayaddlist/', function(data, status){
		data = JSON.parse(data)
		let json_data = data.data;
		yiqinChart.setOption({
			legend: {
				data: json_data.titles
			},
			xAxis: {
				data: json_data.date
			},
			series: json_data.data
		});
	})
	
});
