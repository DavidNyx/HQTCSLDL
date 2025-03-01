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
    public partial class xoasp : Form
    {
        SqlCommand cmd;

        public xoasp()
        {
            InitializeComponent();
        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void button3_Click(object sender, EventArgs e)
        {
            string connString = @"Data Source=" + nachos.servername + ";Initial Catalog=" + nachos.dbname + ";Integrated Security=True;" + "UID=" + nachos.username.Trim() + "password=" + nachos.password.Trim();
            nachos.sqlCon = new SqlConnection(connString);
            if (textBox3.Text != "")
                {
                    SqlDataAdapter adapt1 = new SqlDataAdapter("SELECT madoitac from doitac where doitac.madoitac = '" + textBox3.Text + "' ", nachos.sqlCon);
                    DataTable table1 = new DataTable();
                    adapt1.Fill(table1);
                    if (table1.Rows.Count < 1)
                    {
                        MessageBox.Show("Mã đối tác không tồn tại!");
                    }
                    else
                    {
                        nachos.sqlCon.Open();
                        SqlDataAdapter adapt = new SqlDataAdapter("SELECT DISTINCT QUANLYKHO.masp, quanlykho.macn, sanpham.tensp, sanpham.maloai, sanpham.mota, sanpham.gia from sanpham, quanlykho where QUANLYKHO.MASP = SANPHAM.MASP AND quanlykho.madoitac = '" + textBox3.Text + "'", nachos.sqlCon);
                        DataTable table = new DataTable();
                        adapt.Fill(table);
                        dataGridView1.DataSource = new BindingSource(table, null);
                        nachos.sqlCon.Close();
                    }
                }
                else
                {
                    MessageBox.Show("Vui lòng nhập mã đối tác để được coi danh sách sản phẩm!");
                }
           
        }

        private void textBox3_TextChanged(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            string connString = @"Data Source=" + nachos.servername + ";Initial Catalog=" + nachos.dbname + ";Integrated Security=True;" + "UID=" + nachos.username.Trim() + "password=" + nachos.password.Trim();
            nachos.sqlCon = new SqlConnection(connString);
            if (textBox1.Text != "" || textBox3.Text != "")
               {
                nachos.sqlCon.Open();
                //CHECK SP CO THUOC DOI TAC DO KHONG
                SqlDataAdapter adapt2 = new SqlDataAdapter("SELECT QUANLYKHO.MASP from QUANLYKHO where QUANLYKHO.MASP = '" + textBox1.Text + "' AND QUANLYKHO.MADOITAC = '" + textBox3.Text + "' ", nachos.sqlCon);
                    DataTable table2 = new DataTable();
                    adapt2.Fill(table2);
                    if (table2.Rows.Count < 1)
                    {
                        MessageBox.Show("Sản phẩm không thuộc đối tác này!");
                    }
                    //
                    else
                    {
                        string masp = textBox1.Text, madt = textBox3.Text;
                        
                        cmd = new SqlCommand("EXEC dbo.XOASP '" + masp + "','" + madt + "' ", nachos.sqlCon);
                        cmd.ExecuteNonQuery();
                        nachos.sqlCon.Close();
                        MessageBox.Show("Xóa thành công");
                    }
            }
            else
            {
                    MessageBox.Show("Vui lòng điền thông tin!");
            }
           
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void button2_Click(object sender, EventArgs e)
        {
            this.Hide();
            menudoitac them = new menudoitac();
            them.ShowDialog();
            this.Close();
        }
    }
}
