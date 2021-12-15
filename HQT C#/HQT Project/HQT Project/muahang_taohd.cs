﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Data.SqlClient;

namespace HQT_Project
{
    public partial class muahang_taohd : Form
    {
        string connString = @"Data Source=DESKTOP-8PV3Q0P\SQLEXPRESS;Initial Catalog=DATH1;Integrated Security=True";
        private string madh = "HD";
        SqlCommand cmd;
        SqlDataAdapter adapt;
        public muahang_taohd()
        {
            InitializeComponent();
        }

        private void muahang_taohd_Load(object sender, EventArgs e)
        {
            comboBox1.Items.Add("Tiền mặt");
            comboBox1.Items.Add("Thẻ");
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void label5_Click(object sender, EventArgs e)
        {

        }

        private void textBox4_TextChanged(object sender, EventArgs e)
        {

        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void textBox3_TextChanged(object sender, EventArgs e)
        {
            //makh
        }

        private void label3_Click(object sender, EventArgs e)
        {

        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {
            //madoitac
        }

        private void button2_Click(object sender, EventArgs e)
        {
            using (SqlConnection sqlConn = new SqlConnection(connString))
            {
               if (textBox2.Text != "")
                {
                    sqlConn.Open();
                    SqlDataAdapter adapt = new SqlDataAdapter("SELECT distinct sanpham.masp, sanpham.tensp, sanpham.maloai, sanpham.mota, sanpham.gia, quanlykho.slsp from sanpham, quanlykho where quanlykho.masp = sanpham.masp and quanlykho.madoitac = '" + textBox2.Text + "' ", sqlConn);
                    DataTable table = new DataTable();
                    adapt.Fill(table);
                    dataGridView1.DataSource = new BindingSource(table, null);
                    sqlConn.Close();
                }
                else
                {
                    MessageBox.Show("Vui lòng nhập mã đối tác để xem các sản phẩm của đối tác đó!");
                }
            }
        }


        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            
            
        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void comboBox1_SelectedIndexChanged_1(object sender, EventArgs e)
        {
            
        }

        private void button3_Click(object sender, EventArgs e)
        {

        }

        private void button3_Click_1(object sender, EventArgs e)
        {
            using (SqlConnection sqlConn = new SqlConnection(connString))
            {
                sqlConn.Open();
                SqlDataAdapter adapt = new SqlDataAdapter("SELECT * from doitac", sqlConn);
                DataTable table = new DataTable();
                adapt.Fill(table);
                dataGridView2.DataSource = new BindingSource(table, null);
                sqlConn.Close();
            }
        }

        private void dataGridView2_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void textBox1_TextChanged_1(object sender, EventArgs e)
        {
            //masp
        }

        private void textBox4_TextChanged_1(object sender, EventArgs e)
        {
            //slmua
        }

        private void button4_Click(object sender, EventArgs e)
        {
            //ghi nhan
            using (SqlConnection sqlConn = new SqlConnection(connString))
            {
                if (textBox1.Text != "" && textBox2.Text != "")
                {
                    SqlDataAdapter adapt1 = new SqlDataAdapter("SELECT quanlykho.masp from quanlykho where quanlykho.madoitac = '" + textBox2.Text + "' and quanlykho.masp =  '"+textBox1.Text+"' ", sqlConn);
                    DataTable table1 = new DataTable();
                    adapt1.Fill(table1);
                    if (table1.Rows.Count < 1)
                    {
                        MessageBox.Show("Sản phẩm không thuộc đối tác bạn chọn!");
                    }
                    else
                    {
                        SqlDataAdapter adapt2 = new SqlDataAdapter("SELECT quanlykho.slsp from quanlykho where quanlykho.madoitac = '" + textBox2.Text + "' and quanlykho.masp =  '" + textBox1.Text + "' and quanlykho.slsp >= '"+textBox4.Text+"' ", sqlConn);
                        DataTable table2 = new DataTable();
                        adapt2.Fill(table2);
                        if (table2.Rows.Count < 1)
                        {
                            MessageBox.Show("Số lượng sản phẩm vượt quá số lượng trong kho!");
                        }
                        else
                        {
                            string masp = textBox1.Text;
                            int slsp = int.Parse(textBox4.Text);
                            sqlConn.Open();
                            cmd = new SqlCommand("EXEC dbo.INSERT_GHINHAN '" + madh + "','" + masp + "','" + slsp + "' ", sqlConn);
                            cmd.ExecuteNonQuery();
                            sqlConn.Close();
                            MessageBox.Show("Thêm sản phẩm vào đơn hàng thành công");
                        }    
                    }
                }
                else
                {
                    MessageBox.Show("Vui lòng điền thông tin!");
                }
            }
        }

        private void button5_Click(object sender, EventArgs e)
        {
            //tao don hang
            using (SqlConnection sqlConn = new SqlConnection(connString))
            {
                if (textBox2.Text != "" && textBox3.Text != "" && comboBox1.SelectedItem != null)
                {
                    SqlDataAdapter adapt1 = new SqlDataAdapter("SELECT DOITAC.madoitac from DOITAC where madoitac = '" + textBox2.Text + "' ", sqlConn);
                    DataTable table1 = new DataTable();
                    adapt1.Fill(table1);
                    if (table1.Rows.Count < 1)
                    {
                        MessageBox.Show("Mã đối tác không tồn tại!");
                    }
                    else
                    {
                        SqlDataAdapter adapt2 = new SqlDataAdapter("SELECT khachhang.makh from khachhang where khachhang.makh = '" + textBox3.Text + "' ", sqlConn);
                        DataTable table2 = new DataTable();
                        adapt2.Fill(table2);
                        if (table2.Rows.Count < 1)
                        {
                            MessageBox.Show("Mã khách hàng không tồn tại!");
                        }
                        else
                        {
                            //tao ma don hang random
                            int length = 10;
                            while (true)
                            {
                                Random random = new Random();

                                for (int i = 0; i < length; i++)
                                {
                                    int flt = random.Next(10);
                                    madh = madh + flt.ToString();
                                }
                                SqlDataAdapter adapt3 = new SqlDataAdapter("SELECT donhang.madh from donhang where donhang.madh = '" + madh + "' ", sqlConn);
                                DataTable table3 = new DataTable();
                                adapt3.Fill(table3);
                                if (table3.Rows.Count < 1) // neu ma don hang chua ton tai
                                {
                                    label8.Text = madh;
                                    //them don hang moi vao db
                                    string masp = textBox1.Text, madt = textBox2.Text, makh = textBox3.Text;
                                    object selecteditem = comboBox1.SelectedItem;
                                    string value = selecteditem.ToString();
                                    sqlConn.Open();
                                    cmd = new SqlCommand("EXEC dbo.INSERT_DONHANG '" + madh + "','" + madt + "','" + makh + "','" + value +"' ", sqlConn);
                                    cmd.ExecuteNonQuery();
                                    sqlConn.Close();
                                    MessageBox.Show("Tạo đơn hàng thành công");
                                    break;
                                }
                            }
                        }    
                    }
                }
                else
                {
                    MessageBox.Show("Vui lòng điền đầy đủ thông tin!");
                }
            }
        }

        private void label7_Click(object sender, EventArgs e)
        {

        }
    }
}
